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
import SCLAlertView


class SwipeMoviesViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var movieCardView: UIView!
    @IBOutlet var titleLabelPos: UILabel!
    @IBOutlet var descLabelPos: UILabel!
    @IBOutlet var votesLabelPos: UILabel!
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var alertViewResponder = SCLAlertViewResponder(alertview: SCLAlertView());
    
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
    var superLikeAlert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
    var superLikes = [String:Double]();

    var timeRemaining = 0;
    var timerSuperLike: Timer?
    
    var partyName = String();
    var partyID = String();
    var partySize = Int();
    var members = [String]()
    var seenBy = [String:[String]]();
    var currMovieIndx = 0
    var movieStack = [[String: String]](){
        didSet {
            DispatchQueue.main.async{
                self.findNextMovieNotSeenOrSuperliked();
                self.updateMovieCard()
                self.updateDescriptionCard()
            }
        }
    }
    var newMovies = [Movie](){
        didSet {
            DispatchQueue.main.async{
                for movie in self.newMovies{
                    self.movieStack.append(movie.asDict)
                }
            }
        }
    }

    var partyNames = [String]();
    var partyIDs = [String]()
    var readyToLeaveParty = false{
        didSet{
            DispatchQueue.main.async{
                self.updateUserDataForPartyLeave()
                self.directToPartyManagement()
            }
        }
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        partyNameLabel.text = partyName;
        createDescriptionSide()
        createPosterSide()
        retrieveMovieStack()
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
                print("[ACCESS SUCCESS] Retrieve movie stack.")
            } else {
                print("[ACCESS FAIL] Retrieve movie stack.")
            }
        }
    }
    
    // MARK: - Create Movie Card
    func createPosterSide(){
        
        poster.frame = movieCardView.bounds
        poster.layer.cornerRadius = 15.0
        poster.clipsToBounds = true
        
        thumbUpDownPoster.frame = movieCardView.bounds
        thumbUpDownPoster.image = UIImage(named: "thumb_up.png")
        
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
    
    func updateDescriptionCard(){
        
        thumbUpDownDesc.frame = movieCardView.bounds
        thumbUpDownDesc.image = UIImage(named: "thumb_up.png")
        
        let movie = self.movieStack[self.currMovieIndx]
        
        //Create Movie Title
        let titleVal = movie["title"]
        titleLabel.frame = titleLabelPos.bounds
        titleLabel.frame.origin.x = titleLabelPos.frame.origin.x
        titleLabel.frame.origin.y = titleLabelPos.frame.origin.y
        titleLabel.font = titleLabelPos.font
        titleLabel.numberOfLines = titleLabelPos.numberOfLines
        titleLabel.lineBreakMode = titleLabelPos.lineBreakMode
        titleLabel.text = titleVal
        titleLabel.sizeToFit()

        //Create Description
        let descVal = movie["overview"]
        descLabel.frame = descLabelPos.bounds
        descLabel.frame.origin.x = descLabelPos.frame.origin.x
        descLabel.frame.origin.y = descLabelPos.frame.origin.y
        descLabel.font = descLabelPos.font
        descLabel.numberOfLines = descLabelPos.numberOfLines
        descLabel.lineBreakMode = descLabelPos.lineBreakMode
        descLabel.text = descVal
        descLabel.sizeToFit()
        
        //Create Movie Votes
        let votesVal = "Number of Votes: " + movie["num_votes"]!
        votesLabel.frame = votesLabelPos.bounds
        votesLabel.frame.origin.x = votesLabelPos.frame.origin.x
        votesLabel.frame.origin.y = votesLabelPos.frame.origin.y
        votesLabel.font = votesLabelPos.font
        votesLabel.numberOfLines = votesLabelPos.numberOfLines
        votesLabel.lineBreakMode = votesLabelPos.lineBreakMode
        votesLabel.text = votesVal  
        
        //Set All
        descView.addSubview(titleLabel)
        descView.addSubview(descLabel)
        descView.addSubview(votesLabel)
        descView.addSubview(thumbUpDownDesc)
    }
    
    func updateMovieCard(){
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.movieStack[self.currMovieIndx]["poster_path"]!)
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
            currMovieIndx += 1;
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
        superLikeButton.backgroundColor = UIColor(red: 68.0/255.0, green:64.0/255.0, blue: 74.0/255.0, alpha: 1.0)
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
        }
        let currentTimeStamp = NSDate().timeIntervalSince1970
        let timePassed = currentTimeStamp - superLikes[userID]!;
        return timePassed >= 86400 //user has waited 24 hours, now can superlike
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func convertTimeToString(s:Int,m:Int,h:Int) -> String {
        var secString = String(s)
        var minString = String(m)
        var hourString = String(h)
        if (secString.count==1){
            secString = "0"+secString;
        }
        if (minString.count==1){
            minString = "0"+minString;
        }
        if (hourString.count==1){
            hourString = "0"+hourString;
        }
        return "Will be available in: "+hourString+":"+minString+":"+secString
    }
    func startTimer(){
        if timerSuperLike == nil {
            timerSuperLike = Timer.scheduledTimer(timeInterval: 1, target: self,selector: #selector(updateLabel), userInfo: nil, repeats: true)
        }
    }
    func resetTimer(){
        if timerSuperLike != nil {
            timerSuperLike!.invalidate()
            timerSuperLike = nil
            superLikeAlert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alertViewResponder = SCLAlertViewResponder(alertview: SCLAlertView());
        }
    }
    
    func sendNoSuperLikeAvailableAlert(){
        let currentTimeStamp = NSDate().timeIntervalSince1970
        let timeRemaining = 86400 - (currentTimeStamp - superLikes[userID]!);
        self.timeRemaining = Int(round(timeRemaining));
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: self.timeRemaining)
        let timeString = convertTimeToString(s: s,m: m,h: h);
        superLikeAlert.addButton("Okay, I'll Wait!") {
             self.resetTimer()
        }
        alertViewResponder = superLikeAlert.showWarning("No more superlike available!", subTitle: timeString)
        startTimer()
    }
    
    @objc func updateLabel() {
        self.timeRemaining = self.timeRemaining-1;
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds:self.timeRemaining)
        let timeString = convertTimeToString(s: s,m: m,h: h);
        alertViewResponder.setSubTitle(timeString)
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
        let color = UIColor(red: 255.0/255.0, green: 178.0/255.0, blue: 102.0/255.0, alpha: 1)
        let imageVal = UIImage(named: "superlikeheart.png")! as UIImage
        SCLAlertView().showCustom("SuperLiked!", subTitle: "Movie is added to BucketList!", color: color, icon: imageVal)
    }

    // MARK: - Card Flipper
    
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
                    SCLAlertView().showSuccess("Match!", subTitle: "Movie will be added to BucketList")
                }
           }
            
            if !(refuelNeeded){
                self.currMovieIndx += 1
                self.findNextMovieNotSeenOrSuperliked();
                self.updateMovieCard()
                self.updateDescriptionCard()
           }
       }
    }
    
    // MARK: - Leave Party
    
    @IBAction func leavePartyBtnPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Confirm") {
            self.leaveParty()
        }
        alert.addButton("Cancel"){}
        alert.showWarning("Leave Party?", subTitle: "Are you sure?")
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
        self.retrieveUserDataForPartyLeave()
    }
    
    func retrieveUserDataForPartyLeave() {
        db.collection("users").document(self.userID).getDocument { (document, error) in
            if let document = document {
                self.partyNames = document.get("partyNames")! as! [String]
                self.partyIDs = document.get("partyIDs")! as! [String]
                self.readyToLeaveParty = true;
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

