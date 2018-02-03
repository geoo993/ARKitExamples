//
//  UserDefaults+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 02/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation

public enum Setting: String {
    case scaleWithPinchGesture
    case dragOnInfinitePlanes
    
    public static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.dragOnInfinitePlanes.rawValue: true
        ])
    }
}

public extension UserDefaults {
    public func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    public func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
}
