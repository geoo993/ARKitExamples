//
//  CollisionTypes.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 29/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation

struct CollisionTypes : OptionSet {
    
    let rawValue: Int
    static let bottom  = CollisionTypes(rawValue: 1 << 0)
    static let shape = CollisionTypes(rawValue: 1 << 1)
}
