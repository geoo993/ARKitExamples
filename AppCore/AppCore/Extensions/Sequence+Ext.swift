//
//  Sequence+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 20/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation

public extension Sequence {
    // https://stackoverflow.com/questions/39791084/swift-3-array-to-dictionary
    public func toDictionary<K: Hashable, V>(_ selector: (Iterator.Element) throws -> (K, V)?) rethrows -> [K: V] {
        var dict = [K: V]()
        for element in self {
            if let (key, value) = try selector(element) {
                dict[key] = value
            }
        }
        
        return dict
    }
}
