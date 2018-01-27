
import Foundation

public extension CGRect {
    
    public func increaseRect( _ widthPercentage: CGFloat, _ heightPercentage: CGFloat) -> CGRect {
        let startWidth = self.width
        let startHeight = self.height
        let adjustmentWidth = (startWidth * (widthPercentage / 100.0 )) / 2.0
        let adjustmentHeight = (startHeight * (heightPercentage / 100.0)) / 2.0
        return self.insetBy(dx: -adjustmentWidth, dy: -adjustmentHeight)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        let dx = max(minX - point.x, point.x - maxX, 0)
        let dy = max(minY - point.y, point.y - maxY, 0)
        return dx * dy == 0 ? max(dx, dy) : hypot(dx, dy)
    }
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
    
    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }
    
    var centerX: CGFloat {
        get { return midX }
        set { origin.x = newValue - width * 0.5 }
    }
    
    var centerY: CGFloat {
        get { return midY }
        set { origin.y = newValue - height * 0.5 }
    }
    
    func with(center: CGPoint?) -> CGRect {
        return CGRect(center: center ?? self.center, size: size)
    }
    
    func with(centerX: CGFloat?) -> CGRect {
        return CGRect(center: CGPoint(x: centerX ?? self.centerX, y: centerY), size: size)
    }
    
    func with(centerY: CGFloat?) -> CGRect {
        return CGRect(center: CGPoint(x: centerX, y: centerY ?? self.centerY), size: size)
    }
    
    func with(centerX: CGFloat?, centerY: CGFloat?) -> CGRect {
        return CGRect(center: CGPoint(x: centerX ?? self.centerX, y: centerY ?? self.centerY), size: size)
    }
}
