//
//  NSRange+Ext.swift
//  StoryCore
//
//  Created by GEORGE QUENTIN on 22/02/2018.
//  Copyright © 2018 LEXI LABS. All rights reserved.
//

import Foundation

extension CountableClosedRange where Bound == Int {
    var sum: Int {
        let lowerBound = self.lowerBound
        let upperBound = self.upperBound
        let count = self.count
        return (lowerBound * count + upperBound * count) / 2
    }
}

extension Range where Bound == Int {
    public func toNSRange() -> NSRange {
        return NSRange(location: self.lowerBound, length: self.count)
    }
}

extension Range where Bound == String.Index {
    public func toNSRange() -> NSRange {
        let location = self.lowerBound.encodedOffset
        let length = self.upperBound.encodedOffset - self.lowerBound.encodedOffset
        return NSRange(location: location, length: length)
    }

    public func toRangeInt() -> Range<Int> {
        let start = self.lowerBound.encodedOffset
        let end = self.upperBound.encodedOffset
        return start..<end
    }
}

public extension NSRange {

    public init(_ location: Int, _ length: Int) {
        self.location = location
        self.length = length
    }

    public init(range: Range <Int>) {
        self.location = range.lowerBound
        self.length = range.upperBound - range.lowerBound
    }

    public init(_ range: Range <Int>) {
        self.location = range.lowerBound
        self.length = range.upperBound - range.lowerBound
    }

    var startIndex: Int { return location }
    var endIndex: Int { return location + length }
    var asRange: Range<Int> { return location..<location + length }
    var isEmpty: Bool { return length == 0 }

    public func contains(index: Int) -> Bool {
        return index >= location && index < endIndex
    }

    public func clamp(index: Int) -> Int {
        return max(self.startIndex, min(self.endIndex - 1, index))
    }

    public func intersects(range: NSRange) -> Bool {
        return NSIntersectionRange(self, range).isEmpty == false
    }

    public func intersection(range: NSRange) -> NSRange {
        return NSIntersectionRange(self, range)
    }

    public func union(range: NSRange) -> NSRange {
        return NSUnionRange(self, range)
    }
}
