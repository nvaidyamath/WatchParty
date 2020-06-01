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
import FirebaseFirestore
import AVFoundation
import FBSDKLoginKit

class LogInViewController: UIViewController, LoginButtonDelegate {
    
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var fbFrame: UILabel!
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        if (Auth.auth().currentUser != nil) { // User is already signed in
            self.directToHomeScreen()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundVid()
        // Set up UI buttons
        UIUtilities.styleTextField(emailField)
        UIUtilities.styleTextField(passwordField)
        UIUtilities.styleHollowButton(loginButton)
        loginButton.isEnabled = false
        loginButton.layer.borderColor = UIColor.gray.cgColor;
        
        let FBLogIn = FBLoginButton()
        FBLogIn.delegate = self
        FBLogIn.permissions = ["email"]
        FBLogIn.frame = CGRect(x: fbFrame.frame.origin.x , y: fbFrame.frame.origin.y, width: fbFrame.frame.width, height: fbFrame.frame.height)
        //FBLogIn.layer.cornerRadius = 100
        view.addSubview(FBLogIn)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print(error!)
        }
        print("FB Login Successful")
        fbLogin()
    }
    
    func fbLogin() {
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
            }
            else{
                print("success")
                //let uid = authResult?.user.uid
                
            }
        }
    }
    
//    func createUserIfNeeded() {
//        guard let accessToken = FBSDKLoginKit.AccessToken.current else { return }
//        let graphRequest = GraphRequest(graphPath: "/me",
//                     parameters: ["fields": "email, name"],
//                     tokenString: accessToken.tokenString ,
//                     version: nil,
//                     httpMethod: .get)
//        graphRequest.start { (connection, result, error) -> Void in
//            if error != nil{
//                print(error!)
//            }
//            else{
//                print(result)
//            }
//        }
//        Auth.auth().createUser(withEmail: email, password: self.password) { (result, err) in
//            if err != nil{
//                self.errorDisplay.text = err!.localizedDescription
//                self.errorDisplay.alpha = 1
//            } else {
//                let db = Firestore.firestore()
//                db.collection("users").document(result!.user.uid).setData([
//                    "first_name": firstName,
//                    "last_name": lastName,
//                    "email": self.email,
//                    "partyIDs": [String](),
//                    "partyNames": [String](),
//                    "userName": firstName + " " + lastName]){ (err) in
//                    if err != nil {
//                        self.errorDisplay.text = err!.localizedDescription
//                        self.errorDisplay.alpha = 1
//                    }
//                }
//                self.isUserCreated = true
//            }
//        }
//    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("logged out of FB")
    }
    // MARK: - Log-In Actions
    @IBAction func emailFieldChanged(_ sender: Any) {
        self.shouldEnableLogin()
    }
    
    @IBAction func passwordFieldChanged(_ sender: Any) {
        self.shouldEnableLogin()
    }
    
    func shouldEnableLogin(){
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (email.count > 0 && password.count > 0) {
            loginButton.isEnabled = true
            loginButton.layer.borderColor = UIColor.black.cgColor;
        } else {
            loginButton.isEnabled = false
            loginButton.layer.borderColor = UIColor.gray.cgColor;
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Attempt user sign in
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if err != nil{
                // Wrong password or account does not exist
                self.shakePasswordField()
            } else {
                // Sign in success
                self.directToHomeScreen()
            }
        }
    }
    
    func shakePasswordField(currNumShakes: Int = 0, direction: CGFloat = 1) {
        UIView.animate(withDuration: 0.03, animations: { () -> Void in
            self.passwordField.transform = CGAffineTransform(translationX: 6 * direction, y: 0)
            }, completion: { (aBool :Bool) -> Void in
                if (currNumShakes < 10) {
                    self.shakePasswordField(currNumShakes: currNumShakes + 1, direction: direction * -1)
                } else {
                    self.passwordField.transform = CGAffineTransform.identity
                    self.passwordField.becomeFirstResponder()
                }
        })
    }
    
    func directToHomeScreen(){
        let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        self.view.window?.rootViewController = partyManagementVC
        self.view.window?.makeKeyAndVisible()
    }
    
    
    // MARK: - Background Video
    func setupBackgroundVid(){
        let theURL = Bundle.main.url(forResource:"production ID_3843425", withExtension: "mp4")

        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none

        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: .zero, completionHandler: nil)
    }
    
}

