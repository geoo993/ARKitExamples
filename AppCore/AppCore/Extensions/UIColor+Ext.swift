
// https://gist.github.com/nbasham/3b2de0566d5f716894fc
// https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios

import UIKit

public struct ColorComponents {
    var r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat
}

public extension UIColor {
 
    public convenience init(colorArray array: NSArray) {
        let r = array[0] as! CGFloat
        let g = array[1] as! CGFloat
        let b = array[2] as! CGFloat
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha:1.0)
    }
    
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start.encodedOffset)
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
    
    public convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    public convenience init(rgba: String) {
        // https://raw.githubusercontent.com/yeahdongcn/UIColor-Hex-Swift/master/UIColorExtension.swift
        var red: Double   = 0.0
        var green: Double = 0.0
        var blue: Double  = 0.0
        var alpha: Double = 1.0
        
        if rgba.hasPrefix("#") {
            let start = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex = rgba.substring(from: start.encodedOffset)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                let numElements = hex.count
                if numElements == 6 {
                    red   = Double((hexValue & 0xFF0000) >> 16) / 255.0
                    green = Double((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = Double(hexValue & 0x0000FF) / 255.0
                } else if numElements == 8 {
                    red   = Double((hexValue & 0xFF000000) >> 24) / 255.0
                    green = Double((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = Double((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = Double(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9", terminator: "")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix", terminator: "")
        }
        self.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    public convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
    
    convenience private init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }   
    
    public static var random : UIColor {
        return UIColor(red:   .rand(),
                       green: .rand(),
                       blue:  .rand(),
                       alpha: 1.0)
    }
    
    public  var redValue: CGFloat {
        return cgColor.components! [0]
    }
    
    public  var greenValue: CGFloat {
        return cgColor.components! [1]
    }
    
    public var blueValue: CGFloat {
        return cgColor.components! [2]
    }
    
    public var alphaValue: CGFloat {
        return cgColor.components! [3]
    }
    
    public var rgbValues : (r:CGFloat, g:CGFloat,b:CGFloat, a:CGFloat){
        return (r:redValue, g:greenValue, b: blueValue, a:alphaValue)
    }
    
    public var components : ColorComponents {
        if (self.cgColor.numberOfComponents == 2) {
            let cc = self.cgColor.components;
            return ColorComponents(r:cc![0], g:cc![0], b:cc![0], a:cc![1])
        }
        else {
            let cc = self.cgColor.components;
            return ColorComponents(r:cc![0], g:cc![1], b:cc![2], a:cc![3])
        }
    }
    
    /// The RGBA components associated with a `UIColor` instance.
    public var colorComponents: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let components = self.cgColor.components!
        
        switch components.count == 2 {
        case true : return (r: components[0], g: components[0], b: components[0], a: components[1])
        case false: return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }
    
    public static func interpolateRGBColorWithWhite(start:UIColor,end:UIColor, fraction:CGFloat) -> UIColor
    {
        var f = max(0, fraction)
        f = min(1, fraction)
        
        let c1 = start.components
        let c2 = end.components
        
        let r: CGFloat = CGFloat(c1.r + (c2.r - c1.r) * f)
        let g: CGFloat = CGFloat(c1.g + (c2.g - c1.g) * f)
        let b: CGFloat = CGFloat(c1.b + (c2.b - c1.b) * f)
        let a: CGFloat = CGFloat(c1.a + (c2.a - c1.a) * f)
        
        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }
    
    public static func interpolate(from fromColor: UIColor, to toColor: UIColor, with progress: CGFloat) -> UIColor {
        let fromComponents = fromColor.colorComponents
        let toComponents = toColor.colorComponents
        
        let r = (1 - progress) * fromComponents.r + progress * toComponents.r
        let g = (1 - progress) * fromComponents.g + progress * toComponents.g
        let b = (1 - progress) * fromComponents.b + progress * toComponents.b
        let a = (1 - progress) * fromComponents.a + progress * toComponents.a
        
        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }
   
    public static func segmentColor(speed: Double, 
                                    midSpeed: Double, 
                                    slowestSpeed: Double, 
                                    fastestSpeed: Double) -> UIColor {
        enum BaseColors {
            static let r_red: CGFloat = 1
            static let r_green: CGFloat = 20 / 255
            static let r_blue: CGFloat = 44 / 255
            
            static let y_red: CGFloat = 1
            static let y_green: CGFloat = 215 / 255
            static let y_blue: CGFloat = 0
            
            static let g_red: CGFloat = 0
            static let g_green: CGFloat = 146 / 255
            static let g_blue: CGFloat = 78 / 255
        }
        
        let red, green, blue: CGFloat
        
        if speed < midSpeed {
            let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
            red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
            green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
            blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
        } else {
            let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
            red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
            green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
            blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    /**
     Returns a hex equivalent of this UIColor.
     
     - Parameter includeAlpha:   Optional parameter to include the alpha hex.
     
     color.hexDescription() -> "ff0000"
     
     color.hexDescription(true) -> "ff0000aa"
     
     - Returns: A new string with `String` with the color's hexidecimal value.
     */
    private func hexDescription( _ withAlpha: Bool = false) -> String {
        guard self.cgColor.numberOfComponents == 4 else {
            return "Color not RGB."
        }
        let a = self.cgColor.components!.map { Int($0 * CGFloat(255)) }
        let color = String.init(format: "%02x%02x%02x", a[0], a[1], a[2])
        if withAlpha {
            let alpha = String.init(format: "%02x", a[3])
            return "\(color)\(alpha)"
        }
        return color
    }
    
    public func hexDescription(withHash : Bool, includingAlpha: Bool = false) -> String {
        let hexDescription = self.hexDescription(includingAlpha)
        return withHash ? "#" + hexDescription : hexDescription
    }
    
    public var toHexString : String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        //let rgb:Int = (Int)(r * 255)<<16 | (Int)(g * 255)<<8 | (Int)(b * 255)<<0
        //return NSString(format:"#%06x", rgb) as String
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    fileprivate enum UIColorMasks: CUnsignedInt {
        case redMask    = 0xff000000
        case greenMask  = 0x00ff0000
        case blueMask   = 0x0000ff00
        case alphaMask  = 0x000000ff
        
        static func redValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat((value & redMask.rawValue) >> 24) / 255.0
        }
        
        static func greenValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat((value & greenMask.rawValue) >> 16) / 255.0
        }
        
        static func blueValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat((value & blueMask.rawValue) >> 8) / 255.0
        }
        
        static func alphaValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat(value & alphaMask.rawValue) / 255.0
        }
    }
  
}
