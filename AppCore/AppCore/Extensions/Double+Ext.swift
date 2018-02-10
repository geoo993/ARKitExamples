import Foundation

public extension Double {
    
    public var metersToLatitude : Double { return self / (6360500.0) }
    public var metersToLongitude : Double { return self / (5602900.0) }

    public var toRadians: Double { return self * .pi / 180 }
    public var toDegrees: Double { return self * 180 / .pi }

    public func format(f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
    
    public static func random(min: Double, max: Double) -> Double {
        let rand = Double(arc4random()) / Double(UINT32_MAX)
        let minimum = min < max ? min : max 
        return  rand * Swift.abs(Double( min - max)) + minimum
    }
    
    /// Rounds the double to decimal places value
    public func round(to places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
