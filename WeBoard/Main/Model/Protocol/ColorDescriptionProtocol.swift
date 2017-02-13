//
//  ColorDescriptionProtocol.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/2/13.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation
import UIKit

protocol ColorDescriptionPotocol {
    func colorToColorString(withColor color: UIColor) -> String
    func colorStringToColor(withColorString colorString: String) -> UIColor
}

extension ColorDescriptionPotocol {
    func colorToColorString(withColor color: UIColor) -> String {
        switch color {
        case UIColor.black:
            return "black"
        case UIColor.red:
            return "red"
        case UIColor.blue:
            return "blue"
        case UIColor.white:
            return "white"
        case UIColor.yellow:
            return "yellow"
        case UIColor.green:
            return "green"
        case UIColor.orange:
            return "orange"
        default:
            return "black"
        }
    }
    
    func colorStringToColor(withColorString colorString: String) -> UIColor {
        switch colorString {
        case "black":
            return UIColor.black
        case "red":
            return UIColor.red
        case "blue":
            return UIColor.blue
        case "white":
            return UIColor.white
        case "yellow":
            return UIColor.yellow
        case "green":
            return UIColor.green
        case "orange":
            return UIColor.orange
        default:
            return UIColor.black
        }
    }
}
