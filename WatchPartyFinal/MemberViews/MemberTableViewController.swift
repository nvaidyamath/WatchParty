//
//  MemberTableViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/30/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore


class MemberTableViewController: UITableViewController {

    // MARK: - Properties
    
    let db = Firestore.firestore()
    var partyID = String()
    var partyName = String()
    var userDB = [String: [String]]()
    var finishedGetUserDB = false{
        didSet{
            DispatchQueue.main.async {
                self.getPartyMembers()
            }
        }
    }
    var partyMembers = [String](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserDB()
    }
    
    // MARK: - Firebase Data Retrieval
    
    func getPartyMembers(){
        db.collection("parties").document(self.partyID).getDocument { (document, error) in
            if let document = document {
                self.partyMembers = document.get("members") as! [String]
            } else {
                print("Document does not exist!")
            }
        }
    }
    
    func getUserDB(){
        db.collection("users").getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let userID = document.documentID
                    let firstName = document.get("first_name") as! String
                    let lastName = document.get("last_name") as! String
                    self.userDB[userID] = [firstName, lastName]
                }
                self.finishedGetUserDB = true
            }
        }
    }

    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.partyMembers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
        let userID = self.partyMembers[indexPath.row]
        if let userName = self.userDB[userID]{
            cell.textLabel?.text = userName[0] + " " + userName[1]
        }
        return cell
    }
}
