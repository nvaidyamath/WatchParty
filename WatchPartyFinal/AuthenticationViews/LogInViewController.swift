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
import AVFoundation

class LogInViewController: UIViewController {
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        if (Auth.auth().currentUser != nil) { // User is already signed in.
            let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
            view.window?.rootViewController = partyManagementVC
            view.window?.makeKeyAndVisible()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        playVid()
        loginButton.isEnabled = false
        loginButton.layer.borderColor = UIColor.gray.cgColor;
    }
    
    func initUI(){
        UIUtilities.styleTextField(emailField)
        UIUtilities.styleTextField(passwordField)
        UIUtilities.styleHollowButton(loginButton)
    }
    
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
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if err != nil{
                self.shakeTextField(textField: self.passwordField, numberOfShakes:0, direction :1, maxShakes : 10)
            } else {
                let partyManagementVC = self.storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
                self.view.window?.rootViewController = partyManagementVC
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
    
    func shakeTextField (textField : UITextField, numberOfShakes : Int, direction: CGFloat, maxShakes : Int) {
        let interval : TimeInterval = 0.03
        UIView.animate(withDuration: interval, animations: { () -> Void in
            textField.transform = CGAffineTransform(translationX: 5 * direction, y: 0)
            }, completion: { (aBool :Bool) -> Void in
                if (numberOfShakes >= maxShakes) {
                    textField.transform = CGAffineTransform.identity
                    textField.becomeFirstResponder()
                    return
                }
                self.shakeTextField(textField: textField, numberOfShakes: numberOfShakes + 1, direction: direction * -1, maxShakes: maxShakes)
        })
    }
    
    func playVid(){
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

