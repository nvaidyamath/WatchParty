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
    
    var email = String()
    var password = String()
    var isUserCreated = false {
        didSet{
            DispatchQueue.main.async{
                self.signIn()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        errorDisplay.alpha = 0;
    }
    
    func initUI(){
        UIUtilities.styleTextField(firstNameField)
        UIUtilities.styleTextField(lastNameField)
        UIUtilities.styleTextField(emailField)
        UIUtilities.styleTextField(passwordField)
        UIUtilities.styleFilledButtonParty(signUpButton)
        setupBackgroundImage()
    }
    
    func setupBackgroundImage(){
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "popcorn")
        imageView.center = view.center
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    //Check the fields to see if the data is valid.
    func validateFields() -> Bool {
        
        if firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            errorDisplay.text = "Please complete all fields."
            errorDisplay.alpha = 1
            return false
        }
        return true
    }
    
    
    func signIn(){
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, err in
            if err != nil{
                print("Error logging in. Please retry later.")
            } else {
                let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
                self.view.window?.rootViewController = partyManagementVC
                self.view.window?.makeKeyAndVisible()
            }
        }
    }

    @IBAction func signUpPressed(_ sender: Any) {

        if !(validateFields()){
            return
        }
        
        self.email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Register New User
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if err != nil{
                self.errorDisplay.text = "Error creating user, please try again later."
                self.errorDisplay.alpha = 1
            } else {
                let db = Firestore.firestore()
                db.collection("users").document(result!.user.uid).setData([
                    "first_name": firstName,
                    "last_name": lastName,
                    "email": self.email,
                    "partyIDs": [String](),
                    "partyNames": [String](),
                    "userName": firstName + " " + lastName]){ (err) in
                    if err != nil {
                        self.errorDisplay.text = "User data was not able to be processed, please try again later"
                        self.errorDisplay.alpha = 1
                    }
                }
                self.isUserCreated = true
            }
        }
    }
}
