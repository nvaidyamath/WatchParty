//
//  ViewController.swift
//  WatchPartyFinal
//
//  Created by Nikhil Vaidyamath on 4/26/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import FirebaseAuth
class ViewController: UIViewController {
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    override func viewDidAppear(_ animated: Bool) {
        //need to run in viewdidappear due to hierachy
        if Auth.auth().currentUser != nil {
          // User is signed in.
            print("already signed in")
            self.directToMovieSwipe();

        } else {
          // No user is signed in.
          // ...
            print("not signed in")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //testing to see if git pushes changes
        // Do any additional setup after loading the view.
        initUI()
        if Auth.auth().currentUser != nil {
          // User is signed in.
            print("already signed in")
            self.directToMovieSwipe();

        } else {
          // No user is signed in.
          // ...
            print("not signed in")
        }
    
    }
    func directToMovieSwipe() {
       let movieSwipeVC = storyboard?.instantiateViewController(identifier: "MovieSwipe") as? SwipeMoviesViewController
       view.window?.rootViewController = movieSwipeVC
       view.window?.makeKeyAndVisible()
    }

    override func viewWillLayoutSubviews() {
        //Initial video background
        playVideo()
    }
    
    func playVideo(){
        // Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "logInVideo", ofType: "mp4")

        guard bundlePath != nil else {
            return
        }

        // Create a URL from it
        let url = URL(fileURLWithPath: bundlePath!)

        // Create the video player item
        let item = AVPlayerItem(url: url)

        // Create the player
        videoPlayer = AVPlayer(playerItem: item)

        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)

        // Adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)

        view.layer.insertSublayer(videoPlayerLayer!, at: 0)

        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 0.3)

    }
    
    func initUI(){
        UIUtilities.styleFilledButton(signUpButton)
        UIUtilities.styleHollowButton(logInButton)
    }
}

