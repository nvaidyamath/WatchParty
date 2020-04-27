//
//  SignUpViewController.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/27/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var errorDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorDisplay.alpha = 0;
    }
    

    @IBAction func SignUpPressed(_ sender: Any) {
    }
    
}
