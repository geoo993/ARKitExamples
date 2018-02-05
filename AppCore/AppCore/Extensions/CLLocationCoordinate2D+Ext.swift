//
//  CLLocationCoordinate2D+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    public func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians - longitude.toRadians) * cos(coordinate.latitude.toRadians)
        let b = cos(latitude.toRadians) * sin(coordinate.latitude.toRadians) - sin(latitude.toRadians) * cos(coordinate.latitude.toRadians) * cos(coordinate.longitude.toRadians - longitude.toRadians)
        return atan2(a, b)
    }
    
    public func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateBearing(to: coordinate).toDegrees
    }
    
    public func coordinate(with bearing: Double, and distance: Double) -> CLLocationCoordinate2D {
        
        let distRadiansLat = distance.metersToLatitude // earth radius in meters latitude
        let distRadiansLong = distance.metersToLongitude // earth radius in meters longitude
        
        let lat1 = self.latitude.toRadians
        let lon1 = self.longitude.toRadians
        
        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2.toDegrees, longitude: lon2.toDegrees)
    }  

}
