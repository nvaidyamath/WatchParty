//
//  SwipeMoviesViewController.swift
//  WatchPartyFinal
//
//  Created by Nikhil Vaidyamath on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

class SwipeMoviesViewController: UIViewController {

    @IBOutlet var movieObjectView: UIView!
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var partyIdLabel: UILabel!
    var partyName = String();
    var partyID = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        movieObjectView.addGestureRecognizer(gesture)
        partyNameLabel.text = "Party Name: " + partyName;
        partyIdLabel.text = "Party ID: " + partyID;
    }
   
    @IBAction func partiesButtonPressed(_ sender: Any) {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        movieObjectView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)

        let xFromCenter = view.bounds.width / 2 - movieObjectView.center.x

        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)

        let scale = min(100 / abs(xFromCenter), 1)

        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)

        movieObjectView.transform = scaledAndRotated

        if gestureRecognizer.state == .ended {

            if movieObjectView.center.x < (view.bounds.width / 2 - 100) {
                print("Not Interested")
            }
            if movieObjectView.center.x > (view.bounds.width / 2 + 100) {
                print("Interested")
            }

            rotation = CGAffineTransform(rotationAngle: 0)

            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)

            movieObjectView.transform = scaledAndRotated

            movieObjectView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

