//
//  PartyJoinViewController.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/29/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class PartyJoinViewController: UIViewController {
    
    @IBOutlet var partyIdField: UITextField!
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtilities.styleTextField(partyIdField)
        UIUtilities.styleFilledButtonLocked(joinButton)
        joinButton.isEnabled = false
        errorMessage.alpha = 0
        setupBackgroundImage()
    }
    
    func setupBackgroundImage(){
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "popcorn")
        imageView.center = view.center
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    @IBAction func partyIDFieldUpdated(_ sender: Any) {
        let partyID = self.partyIdField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (partyID.count > 0) {
            joinButton.isEnabled = true
            UIUtilities.styleFilledButtonParty(joinButton)
        } else {
            joinButton.isEnabled = false
            UIUtilities.styleFilledButtonLocked(joinButton)
        }
    }

    @IBAction func joinParty(_ sender: Any) {
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        print(partyIdField.text!)
        db.collection("parties").document(partyIdField.text!).getDocument{ (document, error) in
            if let document = document, document.exists {
                let partyName = document.get("name")!
                
                // Update new party member info to database
                db.collection("users").document(userID).updateData([
                    "partyNames": FieldValue.arrayUnion([partyName]),
                    "partyIDs": FieldValue.arrayUnion([self.partyIdField.text!]),
                ])
                db.collection("parties").document(self.partyIdField.text!).updateData([
                    "members": FieldValue.arrayUnion([userID])
                ])
                
                // Direct to party management screen
                let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
                self.view.window?.rootViewController = partyManagementVC
                self.view.window?.makeKeyAndVisible()
            } else{
                self.errorMessage.text = "Invalid Party ID"
                self.errorMessage.alpha = 1;
            }
        }
    }
    
} // END PartyJoinViewController
