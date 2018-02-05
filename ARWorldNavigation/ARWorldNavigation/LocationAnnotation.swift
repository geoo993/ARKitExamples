//
//  LocationAnnotation.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

import CoreLocation
import MapKit

public final class LocationAnnotation: NSObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?
    
    public init(coordinate: CLLocationCoordinate2D, name: String) {
        self.coordinate = coordinate
        self.title = name
        self.subtitle =  "(\(coordinate.latitude),\(coordinate.longitude))"
        super.init()
    }
}
