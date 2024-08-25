//
//  UIColor+Constants.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 06/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
public extension UIColor {
    func imageWith(width:CGFloat, height:CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width:width, height:height))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
public extension UIColor {
    @objc class var blueTwo: UIColor {
        return UIColor(hex: 0x0076FF)
    }
    @objc class var dark: UIColor {
        return UIColor(red: 22.0 / 255.0, green: 22.0 / 255.0, blue: 32.0 / 255.0, alpha: 1.0)
    }
  
    @objc class var squash: UIColor {
        return UIColor(red: 228.0 / 255.0, green: 128.0 / 255.0, blue: 21.0 / 255.0, alpha: 1.0)
    }
    
    @objc class var darkTwo: UIColor {
        return UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }
    @objc class var dark60: UIColor {
        return UIColor(red: 22.0 / 255.0, green: 22.0 / 255.0, blue: 32.0 / 255.0, alpha: 0.6)
    }
    @objc class var charcoalGrey: UIColor { // 0x333D4D
        return UIColor(red: 51.0 / 255.0, green: 61.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
    @objc class var waterMelon: UIColor { // 0x333D4D
        return UIColor(red: 252.0 / 255.0, green: 74.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
    }
    @objc class var algaeGreen: UIColor { // 0x333D4D
        return UIColor(red: 35.0 / 255.0, green: 212.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
    }
    @objc class var eggshellBlue: UIColor { // 0x333D4D
        return UIColor(red: 211.0 / 255.0, green: 246.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
    }

    @objc class var mango: UIColor { // 0x333D4D
        return UIColor(red: 255 / 255.0, green: 166 / 255.0, blue: 41 / 255.0, alpha: 1.0)
    }
    @objc class var coolGrey: UIColor { // 0x8B93A0
        return UIColor(red: 139.0 / 255.0, green: 147.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    }
    @objc class var softBlue: UIColor { // 0x6168E7
        return UIColor(red: 97.0 / 255.0, green: 104.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
    }
    @objc class var veryLightPurple: UIColor { // 0x6168E7
        return UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    @objc class var dusk: UIColor {
        return UIColor(red: 74.0 / 255.0, green: 94.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)
    }
    @objc class var blueyGrey: UIColor { // A7B0BE
        return UIColor(red: 167.0 / 255.0, green: 176.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
    }
    @objc class var darkGreyBlue: UIColor { // A7B0BE
        return UIColor(red: 38.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
    }
    @objc class var warningYellow: UIColor {
        return UIColor(red: 1.0, green: 193.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
    }
    @objc class var positiveGreen: UIColor {
        return UIColor(red: 95.0 / 255.0, green: 173.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
    }
    @objc class var attentionGrabber: UIColor { // F79256
        return UIColor(red: 247.0 / 255.0, green: 146.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
    }
    @objc class var negativeRed: UIColor { // A54657
        return UIColor(red: 165.0 / 255.0, green: 70.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
    }
    @objc class var cloudyBlue: UIColor { // BBC1CE
        return UIColor(red: 187.0 / 255.0, green: 193.0 / 255.0, blue: 206.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var paleGrey: UIColor {
      return UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    }
    @objc class var paleGreyTwo: UIColor { // 0xF7F8F9
        return UIColor(red: 247.0 / 255.0, green: 248.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
    }
    @objc class var paleGrey2: UIColor { // 0xF7F8F9
        return UIColor(red: 236.0 / 255.0, green: 236.0 / 255.0, blue: 239.0 / 254.0, alpha: 1.0)
    }
    @objc class var paleGreyThree: UIColor { // 0xF7F8F9
        return UIColor(red: 248.0 / 255.0, green: 249.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    @objc class var paleGreyFour: UIColor {
        return UIColor(red: 231 / 255.0, green: 237 / 255.0, blue: 244 / 255.0, alpha: 1.0)
    }
    @objc class var tomato80: UIColor {
        return UIColor(red: 228.0 / 255.0, green: 73.0 / 255.0, blue: 41.0 / 255.0, alpha: 0.8)
    }
    @objc class var slateGrey: UIColor { // 0x6D6D72
        return UIColor(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    }
    @objc class var contactGrey: UIColor { // 0xADBFC3
        return UIColor(red: 173.0 / 255.0, green: 191.0 / 255.0, blue: 195.0 / 255.0, alpha: 1.0)
    }
    @objc class var dividerColor: UIColor {
        return UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
    }
    @objc class var defaultGrey: UIColor {
        return UIColor(red: 232.0 / 255.0, green: 233.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }
    @objc class var greyishBrown: UIColor {
        return UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
    }
    @objc class var searchWhite: UIColor {
        return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    @objc class var silver: UIColor {
        return UIColor(red: 215.0 / 255.0, green: 215.0 / 255.0, blue: 219.0  / 255.0, alpha: 1.0)
    }
    @objc class var defaultBlue: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 118.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    @objc class var gunmetal: UIColor {
        return UIColor(red: 72.0 / 255.0, green: 82.0 / 255.0, blue: 96.0  / 255.0, alpha: 1.0)
    }
    @objc class var battleshipGrey: UIColor {
        return UIColor(red: 118 / 255.0, green: 118 / 255.0, blue: 136  / 255.0, alpha: 1.0)
    }
    @objc class var gunmetal20: UIColor {
        return UIColor(red: 72.0 / 255.0, green: 82.0 / 255.0, blue: 96.0  / 255.0, alpha: 0.2)
    }
    @objc class var whiteTwo: UIColor {
        return UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 0.1)
    }
    @objc class var steel: UIColor {
        return UIColor(red: 142.0 / 255.0, green: 142.0 / 255.0, blue: 147.0 / 255.0, alpha: 0.1)
    }
    @objc class var orangeyYellow: UIColor {
        return UIColor(red: 246.0 / 255.0, green: 191.0 / 255.0, blue: 37.0 / 255.0, alpha: 1.0)
    }
    @objc class var yellowishOrange: UIColor {
        return UIColor(red: 1.0, green: 171.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0)
    }
    @objc class var orangeyRed: UIColor {
        return UIColor(red: 250.0 / 255.0, green: 48.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
    }
    @objc class var lipStick: UIColor {
        return UIColor(red: 233.0 / 255.0, green: 51.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)
    }
    @objc class var orangeyYellow2: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 171.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0)
    }
    @objc class var cornflower: UIColor {
        return UIColor(red: 78 / 255.0, green: 116 / 255.0, blue: 240 / 255.0, alpha: 1.0)
    }
    @objc class var orangish: UIColor {
        return UIColor(red: 249 / 255.0, green: 129 / 255.0, blue: 64 / 255.0, alpha: 1.0)
    }
    @objc class var greenblue: UIColor {
        return UIColor(red: 42 / 255.0, green: 208 / 255.0, blue: 130 / 255.0, alpha: 1.0)
    }
    @objc class var greenteal: UIColor {
        return UIColor(red: 14 / 255.0, green: 189 / 255.0, blue: 146 / 255.0, alpha: 1.0)
    }
    @objc class var violet: UIColor {
        return UIColor(red: 137 / 255.0, green: 18 / 255.0, blue: 241 / 255.0, alpha: 1.0)
    }
    @objc class var coralPink: UIColor {
        return UIColor(red: 255 / 255.0, green: 91 / 255.0, blue: 105 / 255.0, alpha: 1.0)
    }
    @objc class var lightPink: UIColor {
        return UIColor(red: 254 / 255.0, green: 219 / 255.0, blue: 223 / 255.0, alpha: 1.0)
    }
    @objc class var whiteThree: UIColor {
        return UIColor(red: 249 / 255.0, green: 249 / 255.0, blue: 249 / 255.0, alpha: 1.0)
    }
    @objc class var whiteFour: UIColor {
        return UIColor(red: 216 / 255.0, green: 216 / 255.0, blue: 216 / 255.0, alpha: 1.0)
    }
    @objc class var paleLilac: UIColor {
        return UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    }
    @objc class var paleLilacTwo: UIColor {
        return UIColor(red: 237 / 255.0, green: 237 / 255.0, blue: 239 / 255.0, alpha: 1.0)
    }
    @objc class var charcoalGrey30: UIColor {
        return UIColor(red: 62 / 255.0, green: 62 / 255.0, blue: 81 / 255.0, alpha: 0.3)
    }
    @objc class var paleLilacThree: UIColor {
        return UIColor(red: 231 / 255.0, green: 231 / 255.0, blue: 234 / 255.0, alpha: 1.0)
    }
    @nonobjc class var paleLilacFour: UIColor {
      return UIColor(red: 224.0 / 255.0, green: 225.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
    }
    @objc class var steelGrey: UIColor {
        return UIColor(red: 118.0 / 255.0, green: 126.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
    }
    @objc class var lightGreyBlue: UIColor {
        return UIColor(red: 167.0 / 255.0, green: 169.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
    }
    @objc class var lightishBlue: UIColor {
        return UIColor(red: 78.0 / 255.0, green: 116.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    }
    @objc class var veryLightBlue: UIColor {
        return UIColor(red: 231.0 / 255.0, green: 237.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }
    @objc class var lightRoyalBlue: UIColor {
        return UIColor(red: 71.0 / 255.0, green: 65.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    @objc class var charcoalGrey2: UIColor {
        return UIColor(red: 62.0 / 255.0, green: 62.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0)
    }
    @objc class var scarlet: UIColor {
        return UIColor(red: 47.0 / 255.0, green: 145.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    }
    @objc class var purpleishBlue: UIColor {
        return UIColor(red: 109.0 / 255.0, green: 72.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    }
    @objc class var aqua: UIColor {
        return UIColor(red: 24.0 / 255.0, green: 227.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
    }
    @objc class var aquaMarine: UIColor {
        return UIColor(red: 56.0 / 255.0, green: 201.0 / 255.0, blue: 225.0 / 255.0, alpha: 1.0)
    }
    @objc class var bubbleGumPink: UIColor {
        return UIColor(red: 252.0 / 255.0, green: 112.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var lightBlueGrey: UIColor {
        return UIColor(red: 196.0 / 255.0, green: 196.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var iceBlue: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 245.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var tealBlue: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 157.0 / 255.0, blue: 171.0 / 255.0, alpha: 1.0)
    }
    
    // MARK: - init hexString
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue: CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
    
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)
        
        let str = String(format: "#%02x%02x%02x", r, g, b)
        return str
    }
}

// MARK: - KREConstants
open class KREConstants: NSObject {
    // Common colors
    public static func backgroundColor() -> UIColor {
        return UIColor(hex: 0xF7F8F9)
    }
    
    public static func textColor() -> UIColor {
        return UIColor.blueyGrey
    }
    
    public static func themeColor() -> UIColor {
        return UIColor(hex: 0x6F88F0)
    }
    
    public static func textColor(alpha: CGFloat) -> UIColor {
        return UIColor(hex: 0x6168E7, alpha: alpha)
    }
}
