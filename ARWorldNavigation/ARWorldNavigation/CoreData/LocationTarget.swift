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

    // MARK: - Save LocationTarget changes in Realm DataBase
    public func writeToRealm( completion: @escaping (Error?) -> Void) {
        do {
            try AppDelegate.realm.write {
                AppDelegate.realm.add(self, update: true)
                completion(nil)
            }
        } catch {
            print("Error saving locationTarget to realm", error)
            completion(error)
        }
    }

    // MARK: - Update `LocationTarget` if it already exists, add it if not.
    func update(with locationTarget: LocationTarget, completion: @escaping (Error?) -> Void) {

        do {
            try AppDelegate.realm.write {
                self.tag = locationTarget.tag
                self.address = locationTarget.address
                self.altitude = locationTarget.altitude
                self.latitude = locationTarget.latitude
                self.longitude = locationTarget.longitude
                AppDelegate.realm.add(self, update: true)
                completion(nil)
            }
        } catch {
            print("Error updating locationTarget in Realm \(error)")
            completion(error)
        }
    }

    func move(toIndex: Int, completion: @escaping (Error?) -> Void) {
        do {
            try AppDelegate.realm.write {
                completion(nil)
            }
        } catch {
            print("Error moving locationTarget in Realm \(error)")
            completion(error)
        }
    }



    // MARK: - Delete LocationTarget in Realm DataBase
    public func deleteFromRealm(completion: @escaping (Error?) -> Void) {
        do {
            try AppDelegate.realm.write {
                AppDelegate.realm.delete(self)
                completion(nil)
            }
        } catch {
            print("Error deleting locationTarget in Realm \(error)")
            completion(error)
        }
    }

}
