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


protocol SegueHandler: class {
    func segueToNext(identifier: String)
    func getPartyInfo(name: String, ID: String)
}

class PartyManagementViewController: UIViewController, SegueHandler {
    @IBOutlet var pageView: UIView!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    
    var selectedPartyName = String()
    var selectedPartyID = String()
    
    func segueToNext(identifier: String) {
        self.performSegue(withIdentifier:identifier, sender: self)
    }
    
    func getPartyInfo(name: String, ID: String) {
        self.selectedPartyName = name
        self.selectedPartyID = ID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpGradientBackground()
        UIUtilities.styleFilledButtonParty(createButton)
        UIUtilities.styleFilledButtonParty(joinButton)
        UIUtilities.styleHollowButton(logoutButton)
    }
    
    func setUpGradientBackground(){
        // Set the size of the layer to be equal to size of the display.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, UIColor(red: 255/255, green: 204/255, blue: 153/255, alpha: 1).cgColor]
        
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        
        // Apply the gradient to the backgroundGradientView.
        self.pageView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LogInViewController
            self.view.window?.rootViewController = loginVC
            self.view.window?.makeKeyAndVisible()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbeddedSelectionSegue" {
            let dvc = segue.destination as! PartySelectionTableViewController
            dvc.delegate = self
        } else if segue.identifier == "SwipeSegue" {
            let dvc = segue.destination as! SwipeMoviesViewController
            dvc.partyName = self.selectedPartyName
            dvc.partyID = self.selectedPartyID
        }
    }
    
} // END PartyManagementViewController
