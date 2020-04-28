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

class PartyCreationViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func submitButtonPressed(_ sender: Any) {
        
        // TODO: Check duplicate party name
        // TODO: Validate Party Name
        
        let partyName = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        let currUser = db.collection("users").document(userID)
        
        currUser.updateData([
            "parties": FieldValue.arrayUnion([partyName])
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
