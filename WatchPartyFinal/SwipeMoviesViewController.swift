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
    
    var currMovieIndx = 0{
        didSet{
            DispatchQueue.main.async{
                self.updateMovieCard(indx: self.currMovieIndx)
            }
        }
    };
    
    var cards = [[String: String]](){
        didSet {
            DispatchQueue.main.async{
                self.updateMovieCard(indx: self.currMovieIndx)
            }
        }
    }
    
    var movies = [Movie](){
        didSet {
            DispatchQueue.main.async{
                var array = [[String: String]]()
                for movie in self.movies{
                    array.append(movie.asDict)
                }
                
                self.db.collection("parties").document(self.partyID).updateData(["movieStack" : FieldValue.arrayUnion(array)]){ (err) in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                
                self.cards += array
            }
        }
    };
    
    func fetchMovies(page:String){
        let movieRequest = MovieRequest(page: page)
        movieRequest.getMovies { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let movies):
                    self.movies = movies
            }
        }
    }
    
    func updateMovieCard(indx: Int){
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.cards[indx]["poster_path"]!)
        let data = try? Data(contentsOf: url!)
        self.moviePoster.image = UIImage(data: data!)
        self.movieTitle.text = self.cards[indx]["title"]!
    }
    
    func retrieveMovieStack(){
        db.collection("parties").document(partyID).getDocument {
            (document, error) in
            if let document = document {
                self.cards = document.get("movieStack") as! [[String: String]]
                self.currMovieIndx = (document.get("swipeProgress") as! [String: Int])[self.userID]!
            } else {
                print("document does not exist")
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
            if movieObjectView.center.x < (view.bounds.width / 2 - 100){ // right swipe
                swiped = true;
                print("Not Interested")
            }else if movieObjectView.center.x > (view.bounds.width / 2 + 100){ // left swipe
                swiped = true;
                print("Interested")
            }
            
            // Return to original position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            movieObjectView.transform = scaledAndRotated
            movieObjectView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
            
            // Update card if fully swiped
            if(swiped){
                if(self.currMovieIndx + 1 == cards.count){
                    let page = String((cards.count / 20) + 1)
                    fetchMovies(page: page)
                }else{
                    self.currMovieIndx += 1
                }
            }
        }
    }
    
    func updateSwipeProgress(){
        db.collection("parties").document(self.partyID).updateData(["swipeProgress." + self.userID : self.currMovieIndx]){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateSwipeProgress()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwipeToBucketList" {
            let dvc = segue.destination as! BucketListViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID
            
            self.updateSwipeProgress()
        }
    }
}

