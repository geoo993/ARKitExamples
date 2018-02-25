//
//  LocationService.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import CoreLocation

public final class LocationService: NSObject, CLLocationManagerDelegate {
   
    public var locationManager: CLLocationManager?
    public var currentLocation: CLLocation?
    public var lastLocation: CLLocation?
    public var initial: Bool = true
    public var userHeading: CLLocationDirection!
    public var locations: [CLLocation] = []
    public var delegate: LocationServiceDelegate?
    
    override public init() {
        super.init()
    }

    convenience public init(manager: CLLocationManager) {
        self.init()

        requestAuthorization(locationManager: manager)
        setup(locationManager: manager)
    }

    func setup(locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation//kCLLocationAccuracyBest The accuracy of the location data
        //locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.

        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        
        self.locationManager = locationManager
    }

    func requestAuthorization(locationManager: CLLocationManager) {
        // you have 2 choice
        // 1. requestAlwaysAuthorization
        // 2. requestWhenInUseAuthorization
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation(locationManager: locationManager)
        case .denied, .notDetermined, .restricted:
            stopUpdatingLocation(locationManager: locationManager)
        }
    }
    
    func startUpdatingLocation(locationManager: CLLocationManager) {
        print("started manager")
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func stopUpdatingLocation(locationManager: CLLocationManager) {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for location in locations {
            // use for real time update location
            updateLocation(of: location)
        }

        // singleton for get last(current) location
        currentLocation = manager.location
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }

        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        userHeading = heading
        NotificationCenter.default.post(name: Notification.Name(rawValue:"myNotificationName"), object: self, userInfo: nil)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined || status != .denied || status != .restricted {
            setup(locationManager: manager)
        }
    }

    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        updateLocationDidFail(with: error)
    }
    
    // Private function
    func updateLocation(of currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.trackingLocation(of: currentLocation)
    }
    
    func updateLocationDidFail(with error: Error) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.trackingLocationDidFail(with: error)
    }
}
