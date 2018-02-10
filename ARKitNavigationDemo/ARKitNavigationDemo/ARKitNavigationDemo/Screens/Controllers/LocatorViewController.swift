//
//  LocatorViewController.swift
//  ARKitNavigationDemo
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ARKit

public class LocatorViewController: UIViewController {

    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var longitudeLabel : UILabel!
    @IBOutlet weak var latitudeLabel : UILabel!
    @IBOutlet weak var altitudeLabel : UILabel!

    let worldCenter = CLLocation(latitude: 0, longitude: 0)
    let locationManager = CLLocationManager()

    override public func viewDidLoad() {
        super.viewDidLoad()

        if ARConfiguration.isSupported {
            locationManager.delegate = self
            
            if getAutorization() {
                mapView.delegate = self
                mapView.showsScale = true
                mapView.showsPointsOfInterest = true

                update(location: worldCenter)
                //getLocation()

                let gesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
                gesture.numberOfTouchesRequired = 1
                mapView.addGestureRecognizer(gesture)
            }

        } else {
            print("ARKit is not compatible with this phone.")
            return
        }

    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    func getAutorization () -> Bool {
        let autorisation = CLLocationManager.authorizationStatus()
        switch autorisation {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .restricted, .denied:
            return false
        case .notDetermined:
            let bundle = Bundle.main
            if bundle.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil {
                locationManager.requestAlwaysAuthorization()
                print("notDetermined but Alway autorization")
                return true
            } else if bundle.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                locationManager.requestWhenInUseAuthorization()
                print("notDetermined but Alway autorization")
                return true
            } else {
                print("No description provided")
                return false
            }
        }
    }


    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        if let map = sender.view as? MKMapView {
            // Get tap point on map
            let touchPoint = sender.location(in: map)

            // Convert map tap point to coordinate
            let coord: CLLocationCoordinate2D = map.convert(touchPoint, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            update(location: location)
        }
    }

    func getLocation () {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }

    func annotateMap(with name : String, location2D: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.coordinate = location2D
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }

    func update(location: CLLocation) {
        let span : MKCoordinateSpan = MKCoordinateSpanMake(5.04, 5.04)
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let altitude = location.altitude
        let translation = worldCenter.translation(toLocation: location)
        let locationPinCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placeMark = MKPlacemark(coordinate: locationPinCoordinate)
        let region = MKCoordinateRegionMake(locationPinCoordinate, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true

        //annotateMap(with: CLPlacemark, location2D: locationPinCoordinate)

        print("latitude",latitude,
              ", latitude trans",translation.latitudeTranslation,
              ", longitude",longitude,
              ", longitude trans",translation.longitudeTranslation,
              ", altitude",altitude,
              ", altitude trans",translation.altitudeTranslation,
              ", speed", location.speed)

        DispatchQueue.main.async { [unowned self] () in
            self.longitudeLabel.text = "longitude: \(longitude)"
            self.latitudeLabel.text = "latitude: \(latitude)"
            self.altitudeLabel.text = "altitude: \(altitude)"
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension LocatorViewController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if let location = locations.first {
            //update(location: location)
        //}
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined || status != .denied || status != .restricted {
            getLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocatorViewController: MKMapViewDelegate {

}

