//
//  ShapeType.swift
//  ARPrimitives
//
//  Created by GEORGE QUENTIN on 22/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation

public enum ShapeType:Int {
    
    case box
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    case path
    
    public static var random : ShapeType {
        let maxValue = path.rawValue
        let rand = Int.random(min: 0, max: maxValue) 
        return ShapeType(rawValue: rand)!
    }
}
