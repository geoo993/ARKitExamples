//
//  LocationServiceDelegate.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 25/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import CoreLocation

public protocol LocationServiceDelegate {
    func trackingLocation(of currentLocation: CLLocation)
    func trackingLocationDidFail(with error: Error)
}
