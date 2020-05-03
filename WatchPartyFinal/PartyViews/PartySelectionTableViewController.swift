//
//  PartySelectionTableViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore


class PartySelectionTableViewController: UITableViewController {
    
    weak var delegate: SegueHandler?
    var vSpinner : UIView?
    var partyIDs = [String]()
    var partyNames = [String](){
        didSet{
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrievePartyList()
    }
    
    func forceLogOut(){
        // try log-out
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LogInViewController
        self.view.window?.rootViewController = loginVC
        self.view.window?.makeKeyAndVisible()
    }

    
    func retrievePartyList(){
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document {
                if (document.get("partyNames") == nil || document.get("partyIDs") == nil){
                    print("Database Cache Error - Forced Log out")
                    self.forceLogOut();  //helps deal with cache error (when database is deleted, and user is still logged in)
                    return
                }
                self.partyNames = document.get("partyNames")! as! [String]
                self.partyIDs = document.get("partyIDs")! as! [String]
            } else {
                print("[FIREBASE FAIL] Retrieve party list")
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.partyNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyCell", for: indexPath)
        cell.textLabel?.text = self.partyNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.getPartyInfo(name: self.partyNames[indexPath.row], ID: self.partyIDs[indexPath.row])
        delegate?.segueToNext(identifier: "SwipeSegue")
    }
}
