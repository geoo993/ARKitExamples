//
//  CLLocationCoordinate2D+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {

    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// location of 51.5278° N, 0.1025° W => latitude N is positive (51.5278), longitude W is negative (0.1025)
// location of 35.2777° S, 149.1185° E => latitude S is negative (35.2777), longitude E is positive (149.1185)

public extension CLLocationCoordinate2D {
    private func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians - longitude.toRadians) * cos(coordinate.latitude.toRadians)
        let dLat = cos(latitude.toRadians) * sin(coordinate.latitude.toRadians) - sin(latitude.toRadians)
        let dLon = cos(coordinate.latitude.toRadians) * cos(coordinate.longitude.toRadians - longitude.toRadians)
        let b =  dLat * dLon
        return atan2(a, b)
    }
    
    public func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateBearing(to: coordinate).toDegrees
    }

    public func directionValue(to coordinate: CLLocationCoordinate2D) -> Double {
        return self.calculateBearing(to: coordinate)
    }

    public func bearing(to location: CLLocationCoordinate2D) -> Double {

        let lat1 = latitude.toRadians
        let lon1 = longitude.toRadians
        let lat2 = location.latitude.toRadians
        let lon2 = location.longitude.toRadians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x)
        return radiansBearing
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

    public static func intermediaryLocations(from currentLocation: CLLocation, to destinationLocation: CLLocation) -> [CLLocationCoordinate2D] {
        var distances = [CLLocationCoordinate2D]()
        let metersIntervalPerNode: Float = 10
        var distance = Float(destinationLocation.distance(from: currentLocation))
        let bearing = currentLocation.bearing(to: destinationLocation)
        while distance > 10 {
            distance -= metersIntervalPerNode
            let newLocation = currentLocation.coordinate.coordinate(with: Double(bearing), and: Double(distance))
            if !distances.contains(newLocation) {
                distances.append(newLocation)
            }
        }
        return distances
    }

}
