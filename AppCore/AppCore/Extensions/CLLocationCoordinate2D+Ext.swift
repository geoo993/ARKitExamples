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
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return radiansBearing
    }

    public func coordinate(with bearing: Double, and distance: Double) -> CLLocationCoordinate2D {

        let distRadiansLat = distance.metersToLatitude // earth equatorial radius in meters latitude
        let distRadiansLong = distance.metersToLongitude // earth polar radius in meters longitude

        let lat1 = self.latitude.toRadians
        let lon1 = self.longitude.toRadians

        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2.toDegrees, longitude: lon2.toDegrees)
    }

    /*
     The haversine formula determines the great-circle distance between two points on a sphere given their longitudes and latitudes. Important in navigation, it is a special case of a more general formula in spherical trigonometry, the law of haversines, that relates the sides and angles of spherical triangles.
     https://gis.stackexchange.com/questions/4906/why-is-law-of-cosines-more-preferable-than-haversine-when-calculating-distance-b
     https://www.movable-type.co.uk/scripts/latlong.html
     */
    public func haversine(to location: CLLocationCoordinate2D) -> Double {

        let earthRadiusM = Double.earthsEquatorialRadiusMeters // earth equatorial radius in meters latitude
        let lat1 = latitude.toRadians
        let lon1 = longitude.toRadians
        let lat2 = location.latitude.toRadians
        let lon2 = location.longitude.toRadians

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let distance = earthRadiusM * 2.0 * atan2(sqrt(a), sqrt(1-a))

        return distance
    }

    /**
     * Returns the distance between two points on the Earth.
     * Direct translation from http://en.wikipedia.org/wiki/Haversine_formula
     * also refering to the haversine formular here https://www.movable-type.co.uk/scripts/latlong.html
     * @param lat1d Latitude of the first point in degrees
     * @param lon1d Longitude of the first point in degrees
     * @param lat2d Latitude of the second point in degrees
     * @param lon2d Longitude of the second point in degrees
     * @return The distance between the two points in kilometers
     */
    public func distanceEarth(to location: CLLocationCoordinate2D) -> Double {

        let earthRadiusM = Double.earthsEquatorialRadiusMeters // earth equatorial radius in kilometers
        let lat1r = latitude.toRadians
        let lon1r = longitude.toRadians
        let lat2r = location.latitude.toRadians
        let lon2r = location.longitude.toRadians

        let x = sin((lat2r - lat1r)/2)
        let y = sin((lon2r - lon1r)/2)
        let distance = earthRadiusM * 2.0 * asin(sqrt(x * x + cos(lat1r) * cos(lat2r) * y * y))
        return distance
    }

    public static func intermediaryLocations(from currentLocation: CLLocation, to destinationLocation: CLLocation, intervalPerNodeInMeters: Float) -> [CLLocationCoordinate2D] {
        var distances = [CLLocationCoordinate2D]()
        var distance = Float(destinationLocation.distance(from: currentLocation)) // use haversine distance
        let bearing = currentLocation.bearing(to: destinationLocation)
        while distance > intervalPerNodeInMeters {
            distance -= intervalPerNodeInMeters
            let newLocation = currentLocation.coordinate.coordinate(with: Double(bearing), and: Double(distance))
            if !distances.contains(newLocation) {
                distances.append(newLocation)
            }
        }
        return distances
    }

}
