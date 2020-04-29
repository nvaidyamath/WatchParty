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

    var partyNames = [String]()
    var partyIDs = [String]()
    var userRef : DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("entered")
        self.retrievePartyList()
        let db = Firestore.firestore()
        let currentUser = Auth.auth().currentUser
        userRef = db.collection("users").document(currentUser!.uid)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func retrievePartyList(){
        
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let currUser = db.collection("users").document(userID)
        
        currUser.getDocument(source: .cache) { (document, error) in
            if let document = document {
                self.partyNames = document.get("partyNames")! as! [String]
                self.partyIDs = document.get("partyIDs")! as! [String]
                self.tableView.reloadData()
            } else {
                print("Document does not exist in cache")
            }
        }
    }

    // MARK: - Table view data source
    
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.partyNames.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let cell = tableView.dequeueReusableCell(withIdentifier: "PartyCell", for: indexPath)
        let partyManagementVC = PartyManagementViewController();
        let cellVal = cell.textLabel!.text as! String;
        self.userRef.setData([ "currentParty": cellVal], merge: true)
        partyManagementVC.updateLabel(text: cellVal);
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyCell", for: indexPath)
        
        cell.textLabel?.text = self.partyNames[indexPath.row]
        print("tapped")
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
