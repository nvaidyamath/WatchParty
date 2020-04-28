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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        // TODO: Check duplicate party name
        // TODO: Validate Party Name
        
        let partyName = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let userID = Auth.auth().currentUser!.uid
        
        // Create instance of "Party" object
        let members = [userID]
        let bucketList = [String: Int]()
        
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("parties").addDocument(data: [
            "name": partyName,
            "members": members,
            "bucketList": bucketList
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        // Associate party info with user info
        let partyID = ref!.documentID
        let currUser = db.collection("users").document(userID)
        currUser.updateData([
            "partyNames": FieldValue.arrayUnion([partyName]),
            "partyIDs": FieldValue.arrayUnion([partyID])
        ])
        
        self.directToPartyManagement()
    }
    
    func directToPartyManagement() {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
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
