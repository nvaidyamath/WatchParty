//
//  PartyManagementViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
class PartyManagementViewController: UIViewController {
    
    @IBOutlet var currentParty: UILabel!
    var userRef : DocumentReference!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.currentParty.text = "Party: No Party Selected"
        getData();
        userRef.getDocument(source: .cache) { (document, error) in
          if let document = document {
            let dataDescription = document.data()
            if let data = dataDescription!["currentParty"]{
                print("data",data)
                if ((data as! String).count==0){
                    print("here")
                    self.currentParty.text = "Party: No Party Selected"
                }
                self.currentParty.text = data as! String
            }
            else {  //then must add current party field to user
                self.userRef.setData([ "currentParty": "" ], merge: true)
            }
        }

      }
    }
    func updateLabel(text: String){
        self.currentParty.text = text;
    }
    func getData(){
        let db = Firestore.firestore()
        let currentUser = Auth.auth().currentUser
        userRef = db.collection("users").document(currentUser!.uid)
        
    }
    
    func updateCurrentGroup(){
    }
    @IBAction func logOutButton(_ sender: Any) {
         let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
          directToInitialScreen()
        }
        catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
    }
    func directToInitialScreen() {

        let initialVC = storyboard?.instantiateViewController(identifier: "InitialViewController") as? ViewController
        view.window?.rootViewController = initialVC
        view.window?.makeKeyAndVisible()
    }
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
