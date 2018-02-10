//
//  CollisionTypes.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 29/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://www.raywenderlich.com/42699/spritekit-tutorial-for-beginners
// https://stackoverflow.com/questions/26270504/beginner-swift-sprite-kit-node-collision-detection-help-skphysicscontact

import Foundation

public struct CollisionTypes : OptionSet {
    public let rawValue: Int
    public static let bottom  = CollisionTypes(rawValue: 1 << 0)
    public static let shape = CollisionTypes(rawValue: 1 << 1)
    public static let projectile = CollisionTypes(rawValue: 1 << 2)
    public static let target = CollisionTypes(rawValue: 1 << 3)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
