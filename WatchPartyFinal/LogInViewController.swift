//
//  LogInViewController.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/27/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LogInViewController: UIViewController {
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var errorDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        errorDisplay.alpha = 0;
    }
    
    func initUI(){
        UIUtilities.styleTextField(emailField)
        UIUtilities.styleTextField(passwordField)
        UIUtilities.styleHollowButton(loginButton)
    }
    
    func validateFields() -> String? {
        
        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please complete all fields."
        }
        
        //TODO: Check if Password Secure
        
        return nil
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        //Validate
        let error = validateFields()
        
        if(error != nil){
            errorDisplay.text = error!
            errorDisplay.alpha = 1
        }
        else{
            //Sign In
            let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: email, password: password) { result, err in
                if err != nil{
                    self.errorDisplay.text = err!.localizedDescription
                    self.errorDisplay.alpha = 1
                } else {
                    let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
                    self.view.window?.rootViewController = partyManagementVC
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
}

