//
//  PlaceAnnotation.swift
//  ARPlaces
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MapKit

public class PlaceAnnotation: NSObject, MKAnnotation {
    public let coordinate: CLLocationCoordinate2D
    public let title: String?
    public init(location: CLLocationCoordinate2D, title: String) {
        self.coordinate = location
        self.title = title
        
        super.init()
    }
}
