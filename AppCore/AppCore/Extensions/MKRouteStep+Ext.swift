//
//  MKRouteStep+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MapKit

extension MKRoute.Step {
    public var location : CLLocation {
        return CLLocation(latitude: polyline.coordinate.latitude, longitude: polyline.coordinate.longitude)
    }
}
