
import Foundation

public extension NSRange {
    public var toRange : Range<Int> {
        return location ..< (location + length)
    }
}
