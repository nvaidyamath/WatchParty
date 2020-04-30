//
//  BucketListViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/29/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

class BucketListViewController: UIViewController {
    
    var partyName = String();
    var partyID = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BucketListToSwipe" {
            let dvc = segue.destination as! SwipeMoviesViewController
            dvc.partyName = self.partyName
            dvc.partyID = self.partyID
        } else if (segue.identifier == "EmbeddedRankingSegue"){
            let dvc = segue.destination as! RankingTableViewController
            dvc.partyID = self.partyID
        }
    }

}
