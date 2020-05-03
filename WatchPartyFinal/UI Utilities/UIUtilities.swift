//
//  UIUtilities.swift
//  WatchPartyFinal
//
//  Created by Antoine Assaf on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}


class UIUtilities{
    static func styleTextField(_ textfield:UITextField){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height:2)
        bottomLine.backgroundColor = UIColor.init(red:0/255, green: 0/255, blue: 0/255, alpha:1).cgColor
        textfield.borderStyle = .none
        textfield.layer.addSublayer(bottomLine)
    }
        
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20.0
        button.tintColor = UIColor.black
    }
    
    static func styleFilledButtonParty(_ button:UIButton) {
        button.layer.sublayers?[0].removeFromSuperlayer()
        // Filled rounded corner style
        button.layer.cornerRadius = 13.0
        button.tintColor = UIColor.white
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = 13.0
        gradientLayer.colors = [#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).cgColor, UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1).cgColor]
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        gradientLayer.name = "unlocked"
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        //button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25) as! CGColor
    }
    
    static func styleFilledButtonCancel(_ button:UIButton) {
        //button.layer.sublayers?[0].removeFromSuperlayer()
        // Filled rounded corner style
        button.layer.cornerRadius = 13.0
        button.tintColor = UIColor.white
        button.setTitleColor(.white, for: .normal)
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = 13.0
        gradientLayer.colors = [#colorLiteral(red: 1, green: 0.4539142847, blue: 0.4067196846, alpha: 1).cgColor, UIColor(red: 255/255, green: 51/255, blue: 51/255, alpha: 1).cgColor]
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        //button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25) as! CGColor
    }
    
    static func styleFilledButtonLocked(_ button:UIButton) {
        button.layer.sublayers?[0].removeFromSuperlayer()
        // Filled rounded corner style
        button.layer.cornerRadius = 13.0
        button.tintColor = UIColor.white
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = 13.0
        gradientLayer.colors = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor, UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1).cgColor]
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        button.layer.insertSublayer(gradientLayer, at: 0)
        //button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25) as! CGColor
    }
    
    static func circularIcon(_ button:UIButton) {
        button.layer.cornerRadius = button.frame.size.width/2
        button.clipsToBounds = true
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.orange.cgColor
        button.showsTouchWhenHighlighted = true
        button.setBackgroundColor(color: UIColor.lightGray, forState: UIControl.State.highlighted)
        
        
    }
    
    static func nakedIcon(_ button:UIButton) {
        button.layer.cornerRadius = button.frame.size.width/2
        button.clipsToBounds = true
        button.showsTouchWhenHighlighted = true
        button.setBackgroundColor(color: UIColor.lightGray, forState: UIControl.State.highlighted)
    }
    
    
}
