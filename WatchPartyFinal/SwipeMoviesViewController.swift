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


    @IBOutlet weak var partyNameLabel: UILabel!

    @IBOutlet weak var movieCardView: UIView!

    let descView = UIView()
    let descButton = UIButton()
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let votesLabel = UILabel()
    @IBOutlet var titleLabelPos: UILabel!
    @IBOutlet var descLabelPos: UILabel!
    @IBOutlet var votesLabelPos: UILabel!
    
    let thumbUpDownPoster = UIImageView()
    let thumbUpDownDesc = UIImageView()
    
    let posterView = UIView()
    
    let poster = UIImageView()
    let flipButton = UIButton()
    var superLikeButton = UIButton()
    var isDesc = false
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var partyName = String();
    var partyID = String();
    var partySize = Int();
    var members = [String]()
    var seenBy = [String:[String]]();
    var superLikes = [String:Double]();
    var currMovieIndx = 0{
        didSet{
            DispatchQueue.main.async{
                self.updateMovieCard(indx: self.currMovieIndx)
                self.updateDescriptionCard(indx: self.currMovieIndx)
            }
        }
    };
    var movieStack = [[String: String]](){
        didSet {
            DispatchQueue.main.async{
                self.updateMovieCard(indx: self.currMovieIndx)
                self.updateDescriptionCard(indx: self.currMovieIndx)
            }
        }
    }
    var newMovies = [Movie](){
        didSet {
            DispatchQueue.main.async{
                self.createDescriptionSide()
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
    func checkIfSuperLiked()-> Bool{
        if ((self.members.contains(self.movieStack[currMovieIndx]["num_votes"]!))) {
            //self.movieStack[currMovieIndx]["num_votes"] = Auth.auth().currentUser?.displayName
            return true;
        }
        return false;
    }
    func findNextMovieNotSeenOrSuperliked(){
        var nextMovieTitle = self.movieStack[currMovieIndx]["title"]
        while (checkIfSeen(movieTitle: nextMovieTitle!) && checkIfSuperLiked()){
            currMovieIndx+=1;
            nextMovieTitle = self.movieStack[currMovieIndx]["title"]
            
        }
        
    }
   func checkIfSeen(movieTitle:String) -> Bool {
      let seenArray = self.seenBy[movieTitle];
      if (seenArray == nil){
          return false;
      }
      if seenArray!.contains(Auth.auth().currentUser!.uid){
         return true
      }
         return false
    }

    func updateMovieCard(indx: Int){
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.movieStack[indx]["poster_path"]!)
        let data = try? Data(contentsOf: url!)
        self.poster.image = UIImage(data: data!)
        // self.movieTitle.text = self.movieStack[indx]["title"]!
        self.removeSpinner()
    }
    
    func retrieveMovieStack(){
        self.showSpinner(onView: self.view)
        db.collection("parties").document(partyID).getDocument {
            (document, error) in
            if let document = document {
                self.movieStack = document.get("movieStack") as! [[String: String]]
                self.partySize = ((document.get("members")) as! Array<Any>).count
                self.seenBy = document.get("seenBy") as! [String:[String]]
                self.superLikes = document.get("superLikes") as! [String:Double]
                self.currMovieIndx = 0;
                self.findNextMovieNotSeenOrSuperliked();
            } else {
                print("[ACCESS FAIL] Retrieve movie stack")
            }
        }
    }
    
    func createPosterSide(){
        
        poster.frame = movieCardView.bounds
        poster.layer.cornerRadius = 15.0
        poster.clipsToBounds = true
        
        thumbUpDownPoster.frame = movieCardView.bounds
        thumbUpDownPoster.image = UIImage(named: "thumb up.png")
        
        flipButton.frame = poster.frame
        flipButton.addTarget(self, action: #selector(timeToFlip), for: .touchUpInside)
        
        posterView.frame = movieCardView.bounds
        
        posterView.addSubview(flipButton)
        posterView.addSubview(poster)
        posterView.addSubview(thumbUpDownPoster)

    
        superLikeButton = UIButton(frame: CGRect(x: 290, y: 470, width: 75, height: 75))
        let customBackgroundColor = UIColor(red: 68.0/255.0, green:64.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        superLikeButton.backgroundColor = customBackgroundColor
        superLikeButton.layer.cornerRadius = superLikeButton.frame.width/2
        let heartIcon = UIImage(named: "superlikeheart.png") as UIImage?
        superLikeButton.setImage(heartIcon, for: .normal)
        superLikeButton.addTarget(self, action: #selector(superLikeRequested), for: .touchUpInside)
        posterView.addSubview(superLikeButton)
        let gestureFront = UIPanGestureRecognizer(target: self, action: #selector(wasDraggedFront(gestureRecognizer:)))
        let gestureBack = UIPanGestureRecognizer(target: self, action: #selector(wasDraggedBack(gestureRecognizer:)))
        posterView.addGestureRecognizer(gestureFront)
        descView.addGestureRecognizer(gestureBack)
        
        self.movieCardView.addSubview(posterView)
    }
    func checkCanSuperlike() -> Bool{
        let uid = Auth.auth().currentUser!.uid
        if superLikes[uid] == nil {
            return true
        }
        else{
            let currentTimeStamp = NSDate().timeIntervalSince1970
            let timePassed = currentTimeStamp - superLikes[uid]!;
            if (timePassed>=86400){     //user has waited 24 hours, now can superlike
                return true
            }
            else {
                return false
            }
        }
    }
    func sendNoSuperLikeAvailableAlert(){
        let alert = UIAlertController(title: "No SuperLike!", message: "Must Wait!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func superLikeRequested(sender: UIButton!) {
        let timeStamp = NSDate().timeIntervalSince1970
        if (checkCanSuperlike()){
            let currentTimeStamp = NSDate().timeIntervalSince1970
            let uid = Auth.auth().currentUser!.uid
            superLikes[uid] = currentTimeStamp;
            handleSwipe(swiped: 1,superLiked: true);  //treat as a swipe
        }
        else {
            sendNoSuperLikeAvailableAlert()
        }
    }
    func updateDescriptionCard(indx: Int){
        
        thumbUpDownDesc.frame = movieCardView.bounds
        thumbUpDownDesc.image = UIImage(named: "thumb up.png")
        
        //Create Movie Name
        let titleVal = self.movieStack[indx]["title"]
        titleLabel.frame = titleLabelPos.bounds
        titleLabel.frame.origin.x = titleLabelPos.frame.origin.x
        titleLabel.frame.origin.y = titleLabelPos.frame.origin.y
        titleLabel.font = titleLabelPos.font.withSize(60)
        titleLabel.text = titleVal
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping

        //Create Description
        let descVal = self.movieStack[indx]["overview"]
        descLabel.frame = descLabelPos.bounds
        descLabel.frame.origin.x = descLabelPos.frame.origin.x
        descLabel.frame.origin.y = descLabelPos.frame.origin.y
        descLabel.font = descLabelPos.font.withSize(15)
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.text = descVal
        
        //Create Movie Votes
        let votesVal = "Number of Votes: "+self.movieStack[indx]["num_votes"]!
        votesLabel.frame = votesLabelPos.bounds
        votesLabel.frame.origin.x = votesLabelPos.frame.origin.x
        votesLabel.frame.origin.y = votesLabelPos.frame.origin.y
        votesLabel.font = votesLabelPos.font.withSize(15)
        votesLabel.text = votesVal
        votesLabel.numberOfLines = 0
        votesLabel.lineBreakMode = .byWordWrapping
        
        //Set All
        descView.addSubview(titleLabel)
        descView.addSubview(descLabel)
        descView.addSubview(votesLabel)
        descView.addSubview(thumbUpDownDesc)
    }
    
    func createDescriptionSide(){
        
        self.descView.isHidden = false;
        
        descView.layer.cornerRadius = 15.0
        descView.clipsToBounds = true
        descView.backgroundColor = UIColor.orange
        descView.frame = movieCardView.bounds
        descButton.frame = descView.frame
        descButton.addTarget(self, action: #selector(timeToFlip), for: .touchUpInside)
        
        descView.addSubview(descButton)
        self.movieCardView.addSubview(descView)
        
        //Fetch Title
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMovieStack()
        createDescriptionSide()
        descView.isHidden = true
        createPosterSide()
        
        partyNameLabel.text = partyName;
    }
   
    @IBAction func partiesButtonPressed(_ sender: Any) {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
    }

    @IBAction func timeToFlip(_ sender: Any) {
        if isDesc{
            isDesc = false
            UIView.transition(from: descView, to: posterView, duration: 0.4, options: .transitionFlipFromLeft, completion: nil)
            self.descView.isHidden = true;
        } else{
            isDesc = true
            self.descView.isHidden = false;
            flipButton.isEnabled = true
            UIView.transition(from: posterView, to: descView, duration: 0.4, options: .transitionFlipFromLeft, completion: nil)
        }
    }
    @objc func wasDraggedBack(gestureRecognizer: UIPanGestureRecognizer) {
        
        // Calculuate rotation and scaling
        let labelPoint = gestureRecognizer.translation(in: view)
        descView.center = CGPoint(x: movieCardView.bounds.width / 2 + labelPoint.x, y: movieCardView.bounds.height / 2 + labelPoint.y)
        let xFromCenter = view.bounds.width / 2 - descView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: -(xFromCenter / 200))
        let scale = min(100 / abs(xFromCenter), 1)
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        // Apply transformation
        descView.transform = scaledAndRotated
        if xFromCenter < 0{
            thumbUpDownDesc.image = UIImage(named: "thumbs_up.png")?.withRenderingMode(.alwaysTemplate)
            thumbUpDownDesc.tintColor = UIColor.green
        }
        else{
            thumbUpDownDesc.image = UIImage(named: "thumbs_down.png")?.withRenderingMode(.alwaysTemplate)
            thumbUpDownDesc.tintColor = UIColor.red
        }
        thumbUpDownDesc.alpha = abs(xFromCenter) / view.center.x
        
        // Check state when gesture ended
        if gestureRecognizer.state == .ended {
            thumbUpDownDesc.alpha = 0
            var swiped = 0;
            
            if descView.center.x > (view.bounds.width * 0.75){ // right swipe
                swiped = 1
            }else if descView.center.x < (view.bounds.width * 0.25){ // left swipe
                swiped = -1
            }
            
            // Update card if fully swiped
            handleSwipe(swiped: swiped, superLiked: false);
            
            isDesc = false
            UIView.transition(from: descView, to: posterView, duration: 0.4, completion: nil)
            self.descView.isHidden = true;
            
            // Return card to original position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            descView.transform = scaledAndRotated
            descView.center = CGPoint(x: self.movieCardView.bounds.width / 2, y: self.movieCardView.bounds.height / 2)
        }
    }
    
    @objc func wasDraggedFront(gestureRecognizer: UIPanGestureRecognizer) {
        
        // Calculuate rotation and scaling
        let labelPoint = gestureRecognizer.translation(in: view)
        posterView.center = CGPoint(x: movieCardView.bounds.width / 2 + labelPoint.x, y: movieCardView.bounds.height / 2 + labelPoint.y)
        let xFromCenter = view.bounds.width / 2 - posterView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: -(xFromCenter / 200))
        let scale = min(100 / abs(xFromCenter), 1)
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        // Apply transformation
        posterView.transform = scaledAndRotated
        if xFromCenter < 0{
            thumbUpDownPoster.image = UIImage(named: "thumbs_up.png")?.withRenderingMode(.alwaysTemplate)
            thumbUpDownPoster.tintColor = UIColor.green
        }
        else{
            thumbUpDownPoster.image = UIImage(named: "thumbs_down.png")?.withRenderingMode(.alwaysTemplate)
            thumbUpDownPoster.tintColor = UIColor.red
        }
        thumbUpDownPoster.alpha = abs(xFromCenter) / view.center.x
        
        // Check state when gesture ended
        if gestureRecognizer.state == .ended {
            thumbUpDownPoster.alpha = 0
            var swiped = 0;
            
            if posterView.center.x > (view.bounds.width * 0.75){ // right swipe
                swiped = 1
            }else if posterView.center.x < (view.bounds.width * 0.25){ // left swipe
                swiped = -1
            }
            
            // Update card if fully swiped
            handleSwipe(swiped: swiped, superLiked: false);
            
            // Return card to original position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            posterView.transform = scaledAndRotated
            posterView.center = CGPoint(x: self.movieCardView.bounds.width / 2, y: self.movieCardView.bounds.height / 2)
        }
    }
    
    func handleSwipe(swiped:Int, superLiked: Bool){
        if(swiped != 0){
           addSeenMember()
           var refuelNeeded = false;
           if(self.currMovieIndx + 1 == self.movieStack.count){
               print("movie count",self.movieStack.count)
               let page = String((self.movieStack.count / 20) + 1)
                refuelNeeded = true;
               fetchNewMovies(page: page)
           }
           // If it is a right swipe
           if (swiped == 1){
            if (superLiked == false){
                let num_votes = Int(self.movieStack[currMovieIndx]["num_votes"]!)! + 1
                self.movieStack[currMovieIndx]["num_votes"] = String(num_votes)
                if (num_votes == self.partySize){
                    self.sendMatchAlert()
                    self.addToBucketList()
                }
            }
            else {
                self.movieStack[currMovieIndx]["num_votes"] = (Auth.auth().currentUser?.uid)   //superliked, just set value to user who superliked
                self.sendSuperLikeAlert()
                self.addToBucketList()
            }
           }
           if !(refuelNeeded){
               self.currMovieIndx += 1
               findNextMovieNotSeenOrSuperliked();
           }
          
           
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
    func sendSuperLikeAlert(){
        let alert = UIAlertController(title: "SuperLiked!", message: "You have superliked this movie!", preferredStyle: .alert)
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
    
    func updateMovieStack(){
        self.sortStackByVotes()
        db.collection("parties").document(self.partyID).updateData([
            "movieStack" : self.movieStack,"superLikes":self.superLikes,"seenBy": self.seenBy]){ (err) in
            if let err = err {
                print("[UPDATE FAIL] Update swipe progress and votes: \(err)")
            } else {
                print("[UPDATE SUCCESS] Update swipe progress and votes")
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sortByVotes()
        self.updateMovieStack()
    }
    func sortByVotes(){
        self.movieStack.sort { (lhs, rhs) -> Bool in
            if let leftValue = lhs["num_votes"], let leftInt = Int(leftValue), let rightValue = rhs["num_votes"], let rightInt = Int(rightValue) {
                return leftInt > rightInt
            } else {
                return false
            }
        }
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
        self.sortByVotes() //resorts the values
        self.updateMovieStack()
    }
}

