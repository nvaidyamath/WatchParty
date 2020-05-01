//
//  SwipeMoviesViewController.swift
//  WatchPartyFinal
//
//  Created by Nikhil Vaidyamath on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SwipeMoviesViewController: UIViewController {

    @IBOutlet var thumbsImageView: UIImageView!
    @IBOutlet var movieObjectView: UIView!
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet var desriptionView: UIView!
    @IBOutlet var flipperButton: UIButton!
    

    let descView = UIView()
    let descButton = UIButton()
    var isDesc = false
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var partyName = String();
    var partyID = String();
    var partySize = Int();
    var seenBy = [String:[String]]();
    var currMovieIndx = 0{
        didSet{
            DispatchQueue.main.async{
                self.updateMovieCard(indx: self.currMovieIndx)
            }
        }
    };
    var movieStack = [[String: String]](){
        didSet {
            DispatchQueue.main.async{
                self.updateMovieCard(indx: self.currMovieIndx)
            }
        }
    }
    var newMovies = [Movie](){
        didSet {
            DispatchQueue.main.async{
                var array = [[String: String]]()
                for movie in self.newMovies{
                    array.append(movie.asDict)
                }
                
                self.db.collection("parties").document(self.partyID).updateData(["movieStack" : FieldValue.arrayUnion(array)]){ (err) in
                    if let err = err {
                        print("[UPDATE FAIL] Refuel movie stack: \(err)")
                    } else {
                        print("[UPDATE SUCCESS] Refuel movie stack")
                    }
                }
                self.movieStack += array
            }
        }
    };
    
    func fetchNewMovies(page:String){
        let movieRequest = MovieRequest(page: page)
        movieRequest.getMovies { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let movies):
                    self.newMovies = movies
            }
        }
    }
   
    func updateMovieCard(indx: Int){
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.movieStack[indx]["poster_path"]!)
        let data = try? Data(contentsOf: url!)
        self.moviePoster.image = UIImage(data: data!)
        self.movieTitle.text = self.movieStack[indx]["title"]!
        self.removeSpinner()
    }
    
    func retrieveMovieStack(){
        self.showSpinner(onView: self.view)
        db.collection("parties").document(partyID).getDocument {
            (document, error) in
            if let document = document {
                self.movieStack = document.get("movieStack") as! [[String: String]]
                self.currMovieIndx = (document.get("swipeProgress") as! [String: Int])[self.userID]!
                self.partySize = ((document.get("members")) as! Array<Any>).count
                self.seenBy = document.get("seenBy") as! [String:[String]]
            } else {
                print("[ACCESS FAIL] Retrieve movie stack")
            }
        }
    }
    
    func createDescriptionCard(){
        descView.frame =  CGRect(x: movieObjectView.frame.origin.x,
                                 y: movieObjectView.frame.origin.y,
                                 width: movieObjectView.frame.width,
                                 height: movieObjectView.frame.height)
        descView.backgroundColor = UIColor.red
        
        descButton.frame = CGRect(x: flipperButton.frame.origin.x,
                                  y: flipperButton.frame.origin.y,
                                  width: flipperButton.frame.width,
                                  height: flipperButton.frame.height)
        flipperButton.setTitle("", for: .normal)
        descButton.addTarget(self, action: #selector(timeToFlip), for: .touchUpInside)
        descView.addSubview(descButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDescriptionCard()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        movieObjectView.addGestureRecognizer(gesture)
        partyNameLabel.text = "Party Name: " + partyName;
        retrieveMovieStack()
        moviePoster.layer.cornerRadius = 15.0
        moviePoster.clipsToBounds = true
    }
   
    @IBAction func partiesButtonPressed(_ sender: Any) {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
    }

    @IBAction func timeToFlip(_ sender: Any) {
        if isDesc{
            isDesc = false
            UIView.transition(from: descView, to: movieObjectView, duration: 0.4, options: .transitionFlipFromLeft, completion: nil)
        } else{
            isDesc = true
            flipperButton.isEnabled = true
            UIView.transition(from: movieObjectView, to: descView, duration: 0.4, options: .transitionFlipFromLeft, completion: nil)
        }
    }
    
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        // Calculuate rotation and scaling
        let labelPoint = gestureRecognizer.translation(in: view)
        movieObjectView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        let xFromCenter = view.bounds.width / 2 - movieObjectView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: -(xFromCenter / 200))
        let scale = min(100 / abs(xFromCenter), 1)
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        // Apply transformation
        movieObjectView.transform = scaledAndRotated
        if xFromCenter < 0{
            thumbsImageView.image = UIImage(named: "thumbs up.png")?.withRenderingMode(.alwaysTemplate)
            thumbsImageView.tintColor = UIColor.green
        }
        else{
            thumbsImageView.image = UIImage(named: "thumbs down.png")?.withRenderingMode(.alwaysTemplate)
            thumbsImageView.tintColor = UIColor.red
        }
        thumbsImageView.alpha = abs(xFromCenter) / view.center.x
        
        // Check state when gesture ended
        if gestureRecognizer.state == .ended {
            thumbsImageView.alpha = 0
            var swiped = 0;
            
            if movieObjectView.center.x > (view.bounds.width * 0.75){ // right swipe
                swiped = 1
            }else if movieObjectView.center.x < (view.bounds.width * 0.25){ // left swipe
                swiped = -1
            }
            
            // Update card if fully swiped
            if(swiped != 0){
                addSeenMember()
                if(self.currMovieIndx + 1 == self.movieStack.count){
                    let page = String((self.movieStack.count / 20) + 1)
                    fetchNewMovies(page: page)
                }else{
                    self.currMovieIndx += 1
                }
                // If it is a right swipe
                if (swiped == 1){
                    let num_votes = Int(self.movieStack[currMovieIndx]["num_votes"]!)! + 1
                    self.movieStack[currMovieIndx]["num_votes"] = String(num_votes)
                    if (num_votes == self.partySize){
                        self.sendMatchAlert()
                        self.addToBucketList()
                    }
                }
            }
            // Return card to original position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            movieObjectView.transform = scaledAndRotated
            movieObjectView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }
    

    func addSeenMember(){
        let titleVal = self.movieStack[currMovieIndx]["title"];
        if ((self.seenBy[titleVal!]) != nil){
            self.seenBy[titleVal!]! += [Auth.auth().currentUser!.uid]
        }
        else {
            self.seenBy[titleVal!] = [Auth.auth().currentUser!.uid]
        }
    }
    
    
    func addToBucketList(){
        var array = [[String: String]]()
        array.append(self.movieStack[self.currMovieIndx])
        self.db.collection("parties").document(self.partyID).updateData(["bucketList" : FieldValue.arrayUnion(array)]){ (err) in
            if let err = err {
                print("[UPDATE FAIL] Add to bucketlist - \(err)")
            } else {
                print("[UPDATE SUCCESS] Add to bucketlist")
            }
        }
    }
    
    
    func sendMatchAlert(){
        let alert = UIAlertController(title: "Match!", message: "Everyone voted for this movie!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok, add to bucket list!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func sortStackByVotes(){
        self.movieStack.sort { (lhs, rhs) -> Bool in
            if let leftValue = lhs["num_votes"], let leftInt = Int(leftValue), let rightValue = rhs["num_votes"], let rightInt = Int(rightValue) {
                return leftInt > rightInt
            } else {
                return false
            }
        }
    }
    
    func updateSwipeProgressAndMovieStack(){
        self.sortStackByVotes()
        db.collection("parties").document(self.partyID).updateData([
            "swipeProgress." + self.userID : self.currMovieIndx,
            "movieStack" : self.movieStack,"seenBy": self.seenBy]){ (err) in
            if let err = err {
                print("[UPDATE FAIL] Update swipe progress and votes: \(err)")
            } else {
                print("[UPDATE SUCCESS] Update swipe progress and votes")
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateSwipeProgressAndMovieStack()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SwipeToBucketList") {
            let dvc = segue.destination as! BucketListViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID
        } else if (segue.identifier == "SwipeToMemberList"){
            let dvc = segue.destination as! MemberViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID            
        }
        self.updateSwipeProgressAndMovieStack()
    }
}

