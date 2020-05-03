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
        UIUtilities.styleFilledButtonParty(createButton)
        UIUtilities.styleFilledButtonParty(joinButton)
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // Top left corner.
        gradientLayer.endPoint = CGPoint(x: 1, y: 1) // Bottom right corner.
        // Set an array of Core Graphics colors (.cgColor) to create the gradient.
        // This example uses a Color Literal and a UIColor from RGB values.
        gradientLayer.colors = [#colorLiteral(red: 0.1874566376, green: 0.3634057045, blue: 0.7426381707, alpha: 1).cgColor, UIColor(red: 0/255, green: 204/255, blue: 204/255, alpha: 1).cgColor]
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        // Apply the gradient to the backgroundGradientView.
        pageView.layer.insertSublayer(gradientLayer, at: 0)
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
}
