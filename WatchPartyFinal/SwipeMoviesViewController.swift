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

    @IBOutlet var movieObjectView: UIView!
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var partyName = String();
    var partyID = String();
    var partySize = Int();
    
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
    }
    
    func retrieveMovieStack(){
        db.collection("parties").document(partyID).getDocument {
            (document, error) in
            if let document = document {
                self.movieStack = document.get("movieStack") as! [[String: String]]
                self.currMovieIndx = (document.get("swipeProgress") as! [String: Int])[self.userID]!
                self.partySize = ((document.get("members")) as! Array<Any>).count
            } else {
                print("[ACCESS FAIL] Retrieve movie stack")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        movieObjectView.addGestureRecognizer(gesture)
        partyNameLabel.text = "Party Name: " + partyName;
        retrieveMovieStack()
        
    }
   
    @IBAction func partiesButtonPressed(_ sender: Any) {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
    }
    
    func checkMatch(num_votes: Int) -> Bool {
        print("checking match")
        print(num_votes==self.partySize)
        return (num_votes==self.partySize);
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

        // Check state when gesture ended
        if gestureRecognizer.state == .ended {
            
            var swiped = false;
            var interested = false;
            if movieObjectView.center.x > (view.bounds.width / 2 - 100){ // right swipe
                swiped = true;
                interested = true;
            }else if movieObjectView.center.x < (view.bounds.width / 2 + 100){ // left swipe
                swiped = true;
            }
            
            // Return to original position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            movieObjectView.transform = scaledAndRotated
            movieObjectView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
            
            // Right swipe
            if (interested){
                let num_votes = Int(self.movieStack[currMovieIndx]["num_votes"]!)! + 1
                self.movieStack[currMovieIndx]["num_votes"] = String(num_votes)
                if (checkMatch(num_votes: num_votes)){
                    self.sendMatchAlert()
                    self.addToBucketList()
                }
            }
            
            // Update card if fully swiped
            if(swiped){
                if(self.currMovieIndx + 1 == self.movieStack.count){
                    let page = String((self.movieStack.count / 20) + 1)
                    fetchNewMovies(page: page)
                }else{
                    self.currMovieIndx += 1
                }
            }
            
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
    
    
    func updateSwipeProgressAndVotes(){
        db.collection("parties").document(self.partyID).updateData(["swipeProgress." + self.userID : self.currMovieIndx,
                                                                    "movieStack" : self.movieStack]){ (err) in
            if let err = err {
                print("[UPDATE FAIL] Update swipe progress and votes: \(err)")
            } else {
                print("[UPDATE SUCCESS] Update swipe progress and votes")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateSwipeProgressAndVotes()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwipeToBucketList" {
            let dvc = segue.destination as! BucketListViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID
            
            self.updateSwipeProgressAndVotes()
        }
    }
}

