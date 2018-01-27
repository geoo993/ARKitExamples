import Foundation

public extension CGPoint {
    
    public func distance(from rect: CGRect) -> CGFloat {
        let dx = max(rect.minX - x, x - rect.maxX, 0)
        let dy = max(rect.minY - y, y - rect.maxY, 0)
        return dx * dy == 0 ? max(dx, dy) : hypot(dx, dy)
    }
    
    public func distance(to point: CGPoint) -> CGFloat {
        let dx = pow(point.x - self.x, 2)
        let dy = pow(point.y - self.y, 2)
        return sqrt(dx+dy)
    }
    
    public func closestPoint(in points: [CGPoint]) -> CGPoint {
        let lookupTable = points
        let fromPoint = self
        if (lookupTable.count <= 0){ return fromPoint }
        let end = lookupTable.count
        var dd = fromPoint.distanceTo( lookupTable.first!)
        var d: CGFloat = 0
        var f = 0
        for i in 1..<end {
            d = fromPoint.distanceTo( lookupTable[i])
            if d < dd {
                f = i
                dd = d
            }
        }
        return lookupTable[f]
    }
    
    /// Calculates a point at given t value, where t in 0.0...1.0
    public func calculateLinear(t: CGFloat, p1: CGPoint, p2: CGPoint) -> CGPoint {
        let mt : CGFloat = 1.0 - t
        let x = mt * p1.x + t * p2.x
        let y = mt * p1.y + t * p2.y
        return CGPoint(x: x, y: y)
    }
    
    /// Calculates a point at given t value, where t in 0.0...1.0
    public func calculateCube(t: CGFloat, p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint) -> CGPoint {
        let mt : CGFloat = 1.0 - t
        let mt2 = mt * mt
        let t2 = t * t
        
        let a = mt2 * mt
        let b = mt2 * t * 3
        let c = mt * t2 * 3
        let d = t * t2
        
        let x = a * p1.x + b * p2.x + c * p3.x + d * p4.x
        let y = a * p1.y + b * p2.y + c * p3.y + d * p4.y
        return CGPoint(x: x, y: y)
    }
    
    /// Calculates a point at given t value, where t in 0.0...1.0
    public func calculateQuad(t: CGFloat, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let mt : CGFloat = 1.0 - t
        let mt2 = mt * mt
        let t2 = t * t
        
        let a = mt2
        let b = mt * t * 2.0
        let c = t2
        
        let x = a * p1.x + b * p2.x + c * p3.x
        let y = a * p1.y + b * p2.y + c * p3.y
        return CGPoint(x: x, y: y)
    }
    
    
    /**
     * Creates a new CGPoint given a CGVector.
     */
    public init(vector: CGVector) {
        self.init(x: vector.dx, y: vector.dy)
    }
    
    /**
     * Given an angle in radians, creates a vector of length 1.0 and returns the
     * result as a new CGPoint. An angle of 0 is assumed to point to the right.
     */
    public init(angle: CGFloat) {
        self.init(x: cos(angle), y: sin(angle))
    }
    
    /**
     * Adds (dx, dy) to the point.
     */
    public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        x += dx
        y += dy
        return self
    }
    
  
    /**
     * Returns the length (magnitude) of the vector described by the CGPoint.
     */
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    /**
     * Returns the squared length of the vector described by the CGPoint.
     */
    public func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    
    /**
     * Normalizes the vector described by the CGPoint to length 1.0 and returns
     * the result as a new CGPoint.
     */
    func normalized() -> CGPoint {
        let len = length()
        return len>0 ? self / len : CGPoint.zero
    }
    
    /**
     * Normalizes the vector described by the CGPoint to length 1.0.
     */
    public mutating func normalize() -> CGPoint {
        self = normalized()
        return self
    }
    
    /**
     * Calculates the distance between two CGPoints. Pythagoras!
     */
    public func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
    /**
     * Returns the angle in radians of the vector described by the CGPoint.
     * The range of the angle is -π to π; an angle of 0 points to the right.
     */
    public var angle: CGFloat {
        return atan2(y, x)
    }
    
    public func minus(this point: CGPoint) -> CGPoint {
        return self - point
    }
    public func plus(this point: CGPoint) -> CGPoint
    {
        return self + point
    }
   
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

/**
 * Adds two CGPoint values and returns the result as a new CGPoint.
 */
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

/**
 * Increments a CGPoint with the value of another.
 */
public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

/**
 * Adds a CGVector to this CGPoint and returns the result as a new CGPoint.
 */
public func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

/**
 * Increments a CGPoint with the value of a CGVector.
 */
public func += (left: inout CGPoint, right: CGVector) {
    left = left + right
}

/**
 * Subtracts two CGPoint values and returns the result as a new CGPoint.
 */
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

/**
 * Decrements a CGPoint with the value of another.
 */
public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

/**
 * Subtracts a CGVector from a CGPoint and returns the result as a new CGPoint.
 */
public func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

/**
 * Decrements a CGPoint with the value of a CGVector.
 */
public func -= (left: inout CGPoint, right: CGVector) {
    left = left - right
}

/**
 * Multiplies two CGPoint values and returns the result as a new CGPoint.
 */
public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

/**
 * Multiplies a CGPoint with another.
 */
public func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}

/**
 * Multiplies the x and y fields of a CGPoint with the same scalar value and
 * returns the result as a new CGPoint.
 */
public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

/**
 * Multiplies the x and y fields of a CGPoint with the same scalar value.
 */
public func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

/**
 * Multiplies a CGPoint with a CGVector and returns the result as a new CGPoint.
 */
public func * (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
}

/**
 * Multiplies a CGPoint with a CGVector.
 */
public func *= (left: inout CGPoint, right: CGVector) {
    left = left * right
}

/**
 * Divides two CGPoint values and returns the result as a new CGPoint.
 */
public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

/**
 * Divides a CGPoint by another.
 */
public func /= (left: inout CGPoint, right: CGPoint) {
    left = left / right
}

/**
 * Divides the x and y fields of a CGPoint by the same scalar value and returns
 * the result as a new CGPoint.
 */
public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

/**
 * Divides the x and y fields of a CGPoint by the same scalar value.
 */
public func /= (point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}

/**
 * Divides a CGPoint by a CGVector and returns the result as a new CGPoint.
 */
public func / (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
}

/**
 * Divides a CGPoint by a CGVector.
 */
public func /= (left: inout CGPoint, right: CGVector) {
    left = left / right
}

/**
 * Performs a linear interpolation between two CGPoint values.
 */
public func lerp(start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
    return start + (end - start) * t
}
