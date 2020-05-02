//
//  Spinner.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/30/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import Foundation
import UIKit
var vSpinner : UIView?


extension UIViewController {
    func showSpinner(onView : UIView) {

        //Spinner Setup
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        
        //Animate
        ai.startAnimating()
        ai.center = spinnerView.center
        
        //Run in Background, let main thread keep going
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
