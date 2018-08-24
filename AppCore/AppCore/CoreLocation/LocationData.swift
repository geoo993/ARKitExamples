//
//  LocationData.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//
import CoreLocation
import MapKit

public struct LocationData {
    var destinationLocation: CLLocation!
    var annotations: [POIAnnotation]
    var legs: [[CLLocationCoordinate2D]]
    var steps: [MKRoute.Step]
}

