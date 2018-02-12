//
//  LocationTarget.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: Model

public final class LocationTarget: Object {
    @objc dynamic var id = ""

    @objc dynamic var tag : String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var altitude : Double = 0.0
    @objc dynamic var longitude : Double = 0.0
    @objc dynamic var latitude : Double = 0.0

    public convenience init(id: String = NSUUID().uuidString, tag: String, address: String, altitude: Double, longitude : Double, latitude : Double) {
        self.init()
        self.id = id
        self.tag = tag
        self.address = address
        self.altitude = altitude
        self.longitude = longitude
        self.latitude = latitude
    }

    override public static func primaryKey() -> String? {
        return "id"
    }
}

extension LocationTarget {
    public func writeToRealm() {
        try! AppDelegate.realm.write {
            AppDelegate.realm.add(self)
        }
    }
}
