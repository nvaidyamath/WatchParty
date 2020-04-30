//
//  SignUpViewController.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/27/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var errorDisplay: UILabel!
    
    override func viewDidLoad() {
        initUI()
        super.viewDidLoad()
        errorDisplay.alpha = 0;
    }
    
    func initUI(){
        UIUtilities.styleTextField(firstNameField)
        UIUtilities.styleTextField(lastNameField)
        UIUtilities.styleTextField(emailField)
        UIUtilities.styleTextField(passwordField)
        UIUtilities.styleFilledButton(signUpButton)
    }
    
    //Check the fields to see if the data is valid.
    func validateFields() -> String? {
        
        if firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please complete all fields."
        }
        
        // TODO: Check if password is secure
        
        return nil
    }

    @IBAction func signUpPressed(_ sender: Any) {
        let error = validateFields()
        
        if(error != nil){
            errorDisplay.text = error!
            errorDisplay.alpha = 1
        }
        else{
            
            let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let partyNames = [String]()
            let partyIDs = [String]()
            
            //Register New User-=
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                if err != nil{
                    self.errorDisplay.text = "Error Creating User, please try again later"
                    self.errorDisplay.alpha = 1
                }else{
                    let db = Firestore.firestore()
                    db.collection("users").document(result!.user.uid).setData(["first_name":firstName,
                                                                               "last_name":lastName,
                                                                               "email":email,
                                                                               "partyNames":partyNames,
                                                                               "partyIDs":partyIDs]){ (err) in
                        if err != nil {
                            self.errorDisplay.text = "User data was not able to be processed, please try again later"
                            self.errorDisplay.alpha = 1
                        }
                    }
                    
                    //Go to Party Management Screen
                    let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
                    self.view.window?.rootViewController = partyManagementVC
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
}