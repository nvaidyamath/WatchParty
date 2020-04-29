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
class PartyManagementViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
