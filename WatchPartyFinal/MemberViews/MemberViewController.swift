//
//  MemberViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/30/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController {

    var partyName = String();
    var partyID = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MemberToSwipe" {
            let dvc = segue.destination as! SwipeMoviesViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID
        } else if (segue.identifier == "EmbeddedMemberSegue"){
            let dvc = segue.destination as! MemberTableViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID
            
        }
    }
}
