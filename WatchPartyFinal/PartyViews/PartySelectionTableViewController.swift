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
        do {
            try Auth.auth().signOut()
            // direct to initial sign-in/sign-up view
            let initialVC = self.storyboard?.instantiateViewController(identifier: "InitialViewController") as? ViewController
            self.view.window?.rootViewController = initialVC
            self.view.window?.makeKeyAndVisible()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }

    
    func retrievePartyList(){
        
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        print("userID", userID)
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document {
                print("userID inside", userID)
                if (document.get("partyNames")==nil || document.get("partyIDs")==nil){
                    self.forceLogOut();  //helps deal with cache error (when database is deleted, and user is still logged in)
                    
                }
                self.partyNames = document.get("partyNames")! as! [String]
                self.partyIDs = document.get("partyIDs")! as! [String]
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyCell", for: indexPath)
        cell.textLabel?.text = self.partyNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.getPartyInfo(name: self.partyNames[indexPath.row], ID: self.partyIDs[indexPath.row])
        delegate?.segueToNext(identifier: "SwipeSegue")
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
