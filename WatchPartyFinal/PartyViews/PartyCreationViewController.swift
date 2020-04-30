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
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        
        // TODO: Validate Party Name
        
        // Get party name and current userID
        let partyName = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let userID = Auth.auth().currentUser!.uid
        
        // Create instance of "Party" object
        let members = [userID]
        let bucketList = [String:String]()
        let swipeProgress = [userID : 0]
        let seenBy = [String:[String]]();
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("parties").addDocument(data: [
            "name": partyName,
            "members": members,
            "bucketList": bucketList,
            "swipeProgress": swipeProgress,
            "seenBy": seenBy,
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
        
        // Direct back to party management
        let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        self.view.window?.rootViewController = partyManagementVC
        self.view.window?.makeKeyAndVisible()
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
