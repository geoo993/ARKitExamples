import Foundation

public extension FloatingPoint {
    public var toRadians: Self { return self * .pi / 180 }
    public var toDegrees: Self { return self * 180 / .pi }
}

public extension Float {
    public var toRadians : Float { return self * Float.pi / 180.0 }
    public var toDegrees : Float { return self * 180.0 / Float.pi }
    
    public static func rand() -> Float {
        return Float(arc4random()) / Float(UInt32.max)
    }
    
    public static func random(min: Float, max: Float) -> Float {
        let rand = Float(arc4random()) / Float(UINT32_MAX)
        let minimum = min < max ? min : max 
        return  rand * Swift.abs(Float( min - max)) + minimum
    }
}

public extension CGFloat {
    
    public var toRadians : CGFloat { return self * CGFloat.pi / 180.0 }
    public var toDegrees : CGFloat { return self * 180.0 / CGFloat.pi }
    
    public var float: Double {
        return Double(self)
    }
    
    public static func width( ofDevice device: DeviceType) -> (width:CGFloat, exponent: CGFloat) {
        switch device {
        case .iPhone5, .iPhone5s, .iPhone5c, .iPhoneSE:
            return (320.0 , 0.3125)
        case .iPhone6, .iPhone6s, .iPhone7, .iPhone8, .iPhoneX:
            return (375.0 , 0.36621094)
        case .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus:
            return (414.0 , 0.40429688)
        case .iPadMini, .iPadMini2, .iPadMini3, .iPadMini4, 
             .iPad2, .iPad3, .iPad4, .iPad5, .iPadAir, .iPadAir2, .iPadPro9_7:
            return (768.0 , 0.75)
        case .iPadPro10_5:
            return (834.0 , 0.81445312)
        case .iPadPro12_9:
            return (1024.0 , 1.0)
        case .other, .appleTV, .appleTV4K, .simulator:
            return (0.0, 0.0)
        }
    }
    
    public static func height( ofDevice device: DeviceType) -> (height:CGFloat, exponent: CGFloat) {
        switch device {
        case .iPhone5, .iPhone5s, .iPhone5c, .iPhoneSE:
            return (568.0 , 0.41581259)
        case .iPhone6, .iPhone6s, .iPhone7, .iPhone8:
            return (667.0 , 0.4992515)
        case .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus:
            return (736.0 , 0.53879941)
        case .iPhoneX:
            return (812.0 , 0.59443631)
        case .iPadMini, .iPadMini2, .iPadMini3, .iPadMini4, 
             .iPad2, .iPad3, .iPad4, .iPad5, .iPadAir, .iPadAir2, .iPadPro9_7:
            return (1024.0 , 0.74963397)
        case .iPadPro10_5:
            return (1112.0 , 0.81405564)
        case .iPadPro12_9:
            return (1366.0 , 1.0)
        case .other, .appleTV, .appleTV4K, .simulator:
            return (0.0, 0.0)
        }
    }
    
    public static func recommenedWidth( withReferencedDevice device: DeviceType, 
                                        desiredWidth : CGFloat? = nil ) -> CGFloat {
        let referencedDevice = CGFloat.width(ofDevice: device)
        let referencedDeviceWidth = desiredWidth ?? CGFloat.width(ofDevice: device).width
        let size = referencedDeviceWidth / referencedDevice.exponent
        let currentDevice = UIDevice.current.modelName
        let currentDeviceWidthExponent = CGFloat.width(ofDevice: currentDevice).exponent
        return size * currentDeviceWidthExponent
    }
    public static func recommenedHeight(withReferencedDevice device: DeviceType, 
                                        desiredHeight: CGFloat? = nil) -> CGFloat {
        let referencedDevice = CGFloat.height(ofDevice: device)
        let referencedDeviceHeight = desiredHeight ?? CGFloat.height(ofDevice: device).height
        let size = referencedDeviceHeight / referencedDevice.exponent
        let currentDevice = UIDevice.current.modelName
        let currentDeviceHeightExponent = CGFloat.height(ofDevice: currentDevice).exponent
        return size * currentDeviceHeightExponent
    }
    
    public func round(to places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return Darwin.round(self * divisor) / divisor
    }
    
    public static func rand() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        let rand = CGFloat(arc4random()) / CGFloat(UINT32_MAX)
        let minimum = min < max ? min : max 
        return  rand * Swift.abs(CGFloat( min - max)) + minimum
    }
    
    public static func distanceBetween(p1 : CGPoint, p2 : CGPoint) -> CGFloat {
        let dx : CGFloat = p1.x - p2.x
        let dy : CGFloat = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    public static func clamp(value: CGFloat, minimum:CGFloat, maximum:CGFloat) -> CGFloat {
        if value < minimum { return minimum }
        if value > maximum { return maximum }
        return value
    }
    
    public func percentageBetween(maxValue: CGFloat, minValue: CGFloat) -> CGFloat {
        let difference: CGFloat = (minValue < 0) ? maxValue : maxValue - minValue;
        return (CGFloat(100) * ((self - minValue) / difference));
    }
    
    public static func percentangeFromMaxValue(withPercentage percent : CGFloat, maxValue : CGFloat, minValue : CGFloat) -> CGFloat {
        let max = (maxValue > minValue) ? maxValue : minValue
        let min = (maxValue > minValue) ? minValue : maxValue
        
        return ( ((max - min) * percent) / CGFloat(100) ) + min
    }
}


