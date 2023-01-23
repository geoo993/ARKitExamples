
import Foundation

extension NSRange {
    public var toRange : Range<Int> {
        return location ..< (location + length)
    }
}
