//
//  LocationTarget.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//
// https://academy.realm.io/posts/realm-primary-keys-tutorial/
// https://realm.io/docs/swift/latest/

import Foundation
import RealmSwift

// MARK: Model
public class LocationTarget: Object {
    @objc dynamic var locationId : String = NSUUID().uuidString
    
    @objc dynamic var tag : String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var altitude : Double = 0.0
    @objc dynamic var longitude : Double = 0.0
    @objc dynamic var latitude : Double = 0.0

    public convenience init(tag: String,
                            address: String,
                            altitude: Double,
                            longitude : Double,
                            latitude : Double) {
        self.init()
        self.tag = tag
        self.address = address
        self.altitude = altitude
        self.longitude = longitude
        self.latitude = latitude
    }
    
    override public static func primaryKey() -> String? {
        return "locationId"
    }
}

extension LocationTarget {

    // MARK: - Save LocationTarget changes in Realm DataBase
    public func write(to realm: Realm,  completion: @escaping (Error?) -> Void) {
        do {
            try realm.write {
                realm.add(self, update: true)
                completion(nil)
            }
        } catch {
            print("Error saving locationTarget to realm", error)
            completion(error)
        }
    }

    // MARK: - Update `LocationTarget` if it already exists, add it if not.
    public func update(to realm: Realm, with locationTarget: LocationTarget, completion: @escaping (Error?) -> Void) {

        do {
            try realm.write {
                self.tag = locationTarget.tag
                self.address = locationTarget.address
                self.altitude = locationTarget.altitude
                self.latitude = locationTarget.latitude
                self.longitude = locationTarget.longitude
                realm.add(self, update: true)
                completion(nil)
            }
        } catch {
            print("Error updating locationTarget in Realm \(error)")
            completion(error)
        }
    }

    public func move(toIndex: Int, with realm: Realm, completion: @escaping (Error?) -> Void) {
        do {
            try realm.write {
                completion(nil)
            }
        } catch {
            print("Error moving locationTarget in Realm \(error)")
            completion(error)
        }
    }



    // MARK: - Delete LocationTarget in Realm DataBase
    public func delete(from realm: Realm, completion: @escaping (Error?) -> Void) {
        do {
            try realm.write {
                realm.delete(self)
                completion(nil)
            }
        } catch {
            print("Error deleting locationTarget in Realm \(error)")
            completion(error)
        }
    }

}
