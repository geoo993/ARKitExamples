//
//  GrabData.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 21/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Firebase

class GrabData {

/*
 func grabData() {
 let databaseRef = Database.database().reference()
 databaseRef.child("locationTargets").observe(.value, with: { (snapShot) in
 for snap in snapShot.children.allObjects as! [DataSnapshot] {
 guard let dictionary = snap.value as? [String : AnyObject] else { return }
 let tag = dictionary["tag"] as! String
 let address = dictionary["address"] as! String
 let altitude = dictionary["altitude"] as! Double
 let longitude = dictionary["longitude"] as! Double
 let latitude = dictionary["latitude"] as! Double

 print(address, tag, altitude, longitude, latitude)
 let locationTarget = LocationTarget(tag: tag,
 address: address,
 altitude: altitude,
 longitude: longitude,
 latitude: latitude)

 do {
 try RealmObjectServer.realm.write {
 RealmObjectServer.realm.add(locationTarget)
 }
 } catch {
 print("Error updating todo item in Realm \(error)")
 }
 }
 })
 }
 */

}
