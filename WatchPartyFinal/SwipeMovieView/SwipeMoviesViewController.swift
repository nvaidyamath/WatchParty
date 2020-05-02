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

    // MARK: - Properties
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var movieCardView: UIView!
    @IBOutlet var titleLabelPos: UILabel!
    @IBOutlet var descLabelPos: UILabel!
    @IBOutlet var votesLabelPos: UILabel!
    
    let descView = UIView()
    let descButton = UIButton()
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let votesLabel = UILabel()
    let thumbUpDownPoster = UIImageView()
    let thumbUpDownDesc = UIImageView()
    let posterView = UIView()
    let poster = UIImageView()
    let flipButton = UIButton()
    var superLikeButton = UIButton()
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var partyName = String();
    var partyID = String();
    var leavingParty = false;
    var partyNames = [String]();
    var partyIDs = [String](){
        didSet{
            DispatchQueue.main.async{
                if self.leavingParty {
                    self.updateUserDataForPartyLeave()
                    self.directToPartyManagement()
                }
            }
        }
    }
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
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMovieStack()
        createDescriptionSide()
        createPosterSide()
        leavingParty = false
        partyNameLabel.text = partyName;
     }
    
    @IBAction func partiesButtonPressed(_ sender: Any) {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
    }
    
    // MARK: - API and Firestore Calls
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

    func retrieveMovieStack(){
        self.showSpinner(onView: self.view)
        db.collection("parties").document(partyID).getDocument {
            (document, error) in
            if let document = document {
                self.movieStack = document.get("movieStack") as! [[String: String]]
                self.partySize = ((document.get("members")) as! Array<Any>).count
                self.seenBy = document.get("seenBy") as! [String:[String]]
                self.superLikes = document.get("superLikes") as! [String:Double]
                self.members = document.get("members") as! [String]
                self.findNextMovieNotSeenOrSuperliked();
            } else {
                print("[ACCESS FAIL] Retrieve movie stack")
            }
        }
    }
    
    // MARK: - Create Movie Card
    func createPosterSide(){
        
        poster.frame = movieCardView.bounds
        poster.layer.cornerRadius = 15.0
        poster.clipsToBounds = true
        
        thumbUpDownPoster.frame = movieCardView.bounds
        thumbUpDownPoster.image = UIImage(named: "thumb up.png")
        
        flipButton.frame = poster.frame
        flipButton.addTarget(self, action: #selector(timeToFlip), for: .touchUpInside)
        
        createSuperLikeButton()
        
        posterView.frame = movieCardView.bounds

        posterView.addSubview(flipButton)
        posterView.addSubview(poster)
        posterView.addSubview(thumbUpDownPoster)
        posterView.addSubview(superLikeButton)
        
        let gestureFront = UIPanGestureRecognizer(target: self, action: #selector(wasDraggedFront(gestureRecognizer:)))
        posterView.addGestureRecognizer(gestureFront)
        
        self.movieCardView.addSubview(posterView)
    }
    
    func createDescriptionSide(){
                
        descView.layer.cornerRadius = 15.0
        descView.clipsToBounds = true
        descView.backgroundColor = UIColor.orange
        descView.frame = movieCardView.bounds
        descButton.frame = descView.frame
        descButton.addTarget(self, action: #selector(timeToFlip), for: .touchUpInside)
        
        descView.addSubview(descButton)
        
        let gestureBack = UIPanGestureRecognizer(target: self, action: #selector(wasDraggedBack(gestureRecognizer:)))
        descView.addGestureRecognizer(gestureBack)
        
        self.descView.isHidden = true;
        self.movieCardView.addSubview(descView)
    }
    
    func updateDescriptionCard(indx: Int){
        
        thumbUpDownDesc.frame = movieCardView.bounds
        thumbUpDownDesc.image = UIImage(named: "thumb_up.png")
        
        //Create Movie Title
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
    
    func updateMovieCard(indx: Int){
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.movieStack[indx]["poster_path"]!)
        let data = try? Data(contentsOf: url!)
        self.poster.image = UIImage(data: data!)
        self.removeSpinner()
    }

    
    // MARK: - Check If-Seen
    func checkIfSeen() -> Bool {
        let movieTitle = self.movieStack[currMovieIndx]["title"]!
        if let seenArray = self.seenBy[movieTitle] {
            if (seenArray.contains(userID)){
                return true
            }
        }
        return false
    }
     
    func findNextMovieNotSeenOrSuperliked(){
        while (checkIfSeen() || checkIfSuperLiked()){
            currMovieIndx+=1;
        }
    }
    
    func addSeenMember(){
        let movieTitle = self.movieStack[currMovieIndx]["title"]!;
        if ((self.seenBy[movieTitle]) != nil){
            self.seenBy[movieTitle]! += [userID]
        } else {
            self.seenBy[movieTitle] = [userID]
        }
    }

    
    // MARK: - Super Like
    func createSuperLikeButton(){
        superLikeButton = UIButton(frame: CGRect(x: 290, y: 470, width: 75, height: 75))
        let customBackgroundColor = UIColor(red: 68.0/255.0, green:64.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        superLikeButton.backgroundColor = customBackgroundColor
        superLikeButton.layer.cornerRadius = superLikeButton.frame.width/2
        let heartIcon = UIImage(named: "superlikeheart.png") as UIImage?
        superLikeButton.setImage(heartIcon, for: .normal)
        superLikeButton.addTarget(self, action: #selector(superLikeRequested), for: .touchUpInside)
    }
    
    func checkIfSuperLiked()-> Bool{
        return (self.movieStack[currMovieIndx]["superLikedBy"] != "")
    }
    
    func checkCanSuperlike() -> Bool{
        if superLikes[userID] == nil {
            return true
        } else{
            let currentTimeStamp = NSDate().timeIntervalSince1970
            let timePassed = currentTimeStamp - superLikes[userID]!;
            if (timePassed >= 86400){     //user has waited 24 hours, now can superlike
                return true
            } else {
                return false
            }
        }
    }
    
    func sendNoSuperLikeAvailableAlert(){
        let alert = UIAlertController(title: "No more superlike available!", message: "Please Wait 24hrs!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func superLikeRequested(sender: UIButton!) {
        if (checkCanSuperlike()){
            let currentTimeStamp = NSDate().timeIntervalSince1970
            superLikes[userID] = currentTimeStamp;
            handleSwipe(swiped: 1,superLiked: true);  //treat as a swipe
        } else {
            sendNoSuperLikeAvailableAlert()
        }
    }
    
    func sendSuperLikeAlert(){
        let alert = UIAlertController(title: "SuperLiked!", message: "You have superliked this movie!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok, add to bucket list!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func timeToFlip(_ sender: Any) {
        if self.descView.isHidden == false{
            UIView.transition(from: descView, to: posterView, duration: 0.4, options: .transitionFlipFromLeft, completion: nil)
            self.descView.isHidden = true;
        } else{
            self.descView.isHidden = false;
            flipButton.isEnabled = true
            UIView.transition(from: posterView, to: descView, duration: 0.4, options: .transitionFlipFromLeft, completion: nil)
        }
    }
    
    // MARK: - Swipe Handler and Gesture Recognizer
    
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
            
            if(swiped != 0){
                UIView.transition(from: descView, to: posterView, duration: 0.4, completion: nil)
                self.descView.isHidden = true;
            }
            
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
                let page = String((self.movieStack.count / 20) + 1)
                refuelNeeded = true;
                fetchNewMovies(page: page)
            }
            
            // If it is a right swipe
            if (swiped == 1){
                let num_votes = Int(self.movieStack[currMovieIndx]["num_votes"]!)! + 1
                self.movieStack[currMovieIndx]["num_votes"] = String(num_votes)
                self.movieStack[currMovieIndx]["votedBy"] = self.movieStack[currMovieIndx]["votedBy"]! + "," + userID
                
                if superLiked {
                    self.movieStack[currMovieIndx]["superLikedBy"] = userID
                    self.sendSuperLikeAlert()
                } else if (num_votes == self.partySize){
                    self.sendMatchAlert()
                }
           }
            
           if !(refuelNeeded){
               self.currMovieIndx += 1
               findNextMovieNotSeenOrSuperliked();
           }
       }
    }
    
    // MARK: - Bucket list and Match
    func sendMatchAlert(){
        let alert = UIAlertController(title: "Match!", message: "Everyone voted for this movie!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok, add to bucket list!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Leave Party
    
    @IBAction func leavePartyBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Leave Party?", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            self.leavingParty = true
            self.leaveParty()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func leaveParty(){
        // Party: Update members
        print("Leaving Party Sequence Initiated...")
        self.members = self.members.filter { $0 != userID }
        
        // Party: Update movie stack
        for (indx, movie) in self.movieStack.enumerated(){
            var users = movie["votedBy"]!.split(separator: ",")
            for user in users{
                if user == self.userID {
                    users = users.filter { $0 != self.userID}
                    self.movieStack[indx]["votedBy"] = "," + users.joined(separator: ",")
                    self.movieStack[indx]["num_votes"] = String(Int(self.movieStack[indx]["num_votes"]!)! - 1)
                    if self.movieStack[indx]["superLikedBy"]! == self.userID{
                        self.movieStack[indx]["superLikedBy"] = ""
                        self.superLikes.removeValue(forKey: self.userID)
                    }
                }
            }
        }
        self.retrieveUserData()
    }
    
    func retrieveUserData() {
        db.collection("users").document(self.userID).getDocument { (document, error) in
            if let document = document {
                self.partyNames = document.get("partyNames")! as! [String]
                self.partyIDs = document.get("partyIDs")! as! [String]
            } else {
                print("[FIREBASE FAIL] Retrieve user data")
            }
        }
    }
    
    func updateUserDataForPartyLeave() {
        self.partyNames = self.partyNames.filter{$0 != self.partyName}
        self.partyIDs = self.partyIDs.filter{$0 != self.partyID}
        db.collection("users").document(self.userID).updateData([
            "partyNames" : self.partyNames,
            "partyIDs" : self.partyIDs]){ (err) in
            if let err = err {
                print("[UPDATE FAIL] Update user data: \(err)")
            } else {
                print("[UPDATE SUCCESS] Update user data")
            }
        }
    }
    
    // MARK: - Sort and Update Data
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
            "members" : self.members,
            "movieStack" : self.movieStack,
            "superLikes":self.superLikes,
            "seenBy": self.seenBy]){ (err) in
            if let err = err {
                print("[UPDATE FAIL] Update movie stack: \(err)")
            } else {
                print("[UPDATE SUCCESS] Update movie stack")
            }
        }
    }
    
    
    // MARK: - Exiting View
    func directToPartyManagement(){
        let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        self.view.window?.rootViewController = partyManagementVC
        self.view.window?.makeKeyAndVisible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateMovieStack()
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
        self.updateMovieStack()
    }
}

