//
//  LogInViewController.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/27/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var errorDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorDisplay.alpha = 0;
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
    }
    
}
