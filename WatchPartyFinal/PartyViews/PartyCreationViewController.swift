//
//  PartyCreationViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class PartyCreationViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var stack = [[String: String]]()
    
    var movies = [Movie](){
        didSet {
            DispatchQueue.main.async {
                for movie in self.movies{
                    self.stack.append(movie.asDict)
                }
            }
        }
    };
    
    func fetchMovies(){
        let movieRequest = MovieRequest(page: "1")
        movieRequest.getMovies { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let movies):
                    self.movies = movies
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMovies()
        UIUtilities.styleFilledButtonLocked(submitButton)
        UIUtilities.styleTextField(nameField)
        submitButton.isEnabled = false
        setupBackgroundImage()
    }
    
    func setupBackgroundImage(){
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "popcorn")
        imageView.center = view.center
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    @IBAction func partyNameFieldUpdated(_ sender: Any) {
        let partyName = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (partyName.count == 0){
            submitButton.isEnabled = false;
            UIUtilities.styleFilledButtonLocked(submitButton)
        } else {
            submitButton.isEnabled = true;
            UIUtilities.styleFilledButtonParty(submitButton)
        }
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        // Get party name and current userID
        let partyName = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let userID = Auth.auth().currentUser!.uid
       
        // Create instance of "Party" object
        let members = [userID]
        let seenBy = [String:[String]]();
        let superLikes = [String:Double]();
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("parties").addDocument(data: [
            "name": partyName,
            "members": members,
            "seenBy": seenBy,
            "superLikes":superLikes,
            "movieStack": self.stack
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        // Associate party info with user info
        let partyID = ref!.documentID
        db.collection("users").document(userID).updateData([
            "partyNames": FieldValue.arrayUnion([partyName]),
            "partyIDs": FieldValue.arrayUnion([partyID])
        ])
        
        // Direct to party management screen
        let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        self.view.window?.rootViewController = partyManagementVC
        self.view.window?.makeKeyAndVisible()
    }

} // END PartyCreationViewController
