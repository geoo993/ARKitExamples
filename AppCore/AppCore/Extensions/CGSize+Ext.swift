/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit

// MARK: - CGSize extensions

public extension CGSize {
    
	public init(_ point: CGPoint) {
        self.init()
        self.width = point.x
		self.height = point.y
	}

    public var half: CGSize {
        return CGSize(width: self.width / 2, height: self.height / 2)
    }

    public var toCGPoint: CGPoint {
        return CGPoint(x: width, y: height)
    }
}

public func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

public func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

public func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

public func -= (left: inout CGSize, right: CGSize) {
    left = left - right
}

public func *= (left: inout CGSize, right: CGFloat) {
    left = left * right
}

public func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

public func /= (left: inout CGSize, right: CGFloat) {
    left = left / right
}

public func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
}

/**
 * Performs a linear interpolation between two CGPoint values.
 */
public func lerp(start: CGSize, end: CGSize, t: CGFloat) -> CGSize {
    return start + (end - start) * t
}
