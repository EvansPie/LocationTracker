//
//  UIColorExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/3/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var brightBlue: UIColor {
        return UIColor(hex: 0x007AFF)
    }
    
    class var errorRed: UIColor {
        return UIColor(hex: 0xFF3B30)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
    
}
