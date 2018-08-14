//
//  ARWorldNavigationViewController.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-one-fc7cb2fa0150
// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-three-98b1d51e2eac
// https://www.movable-type.co.uk/scripts/latlong.html
// https://developer.apple.com/documentation/arkit/arconfiguration.worldalignment/2873776-gravityandheading
// https://stackoverflow.com/questions/43097932/realm-sync-swift-example
// https://www.youtube.com/watch?v=fwVeP5BLGtA
// https://www.youtube.com/watch?v=7u9-8e-sSJA
// https://academy.realm.io/posts/marin-todorov-building-reactive-apps-with-realm-episode-1-swift-ios/
// https://www.youtube.com/watch?v=wq4HoJGwtoo
// https://stackoverflow.com/questions/47333208/starting-realm-object-server-on-aws-stalls
// https://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
// https://www.youtube.com/watch?v=OYu3bkOyJY8
// https://docs.realm.io/cloud/ios-todo-app


/*

Creating an AR experience depends on being able to construct a coordinate system for placing objects in a virtual 3D world that maps to the real-world position and motion of the device. When you run a session configuration, ARKit creates a scene coordinate system based on the position and orientation of the device; any ARAnchor objects you create or that the AR session detects are positioned relative to that coordinate system.

The position and orientation of the device as of when the session configuration is first run determine the rest of the coordinate system.

 Although, (configuration.worldAlignment = .gravityAndHeading) option fixes the directions of the three coordinate axes to real-world directions, the location of the coordinate system’s origin is still relative to the device, matching the device’s position as of when the session configuration is first run.

 Because ARKit automatically matches SceneKit space to the real world, placing a virtual object such that it appears to maintain a real-world position requires only setting that object’s SceneKit position appropriately.
 
 Matrices are used to transform 3D coordinates. These include:
 - Rotation (changing orientation)
 - Scaling (size changes)
 - Translation (moving position)


 Questions
 - run a new coordinte system by creating a new AR session
 - make that new coordinatesystem of the new AR session the origin of the current running loop
 - record the distance away from that origin point in real world coordinate system (altitude, longitude, latitude), as you move the device.

 - calculate the relative bearing (angle) between phone and a target point and display it on screen
 - then calculate the distance between those two points


 GOAL -- TAP ON A LOCATION AND AR SCENE WILL GUID YOU TO THE OBJECT IN THAT LOCATION

 */

import UIKit
import CoreData
import CoreLocation
import MapKit
import ARKit
import SceneKit
import AppCore
import Realm
import RealmSwift
//import Firebase

public class ARWorldNavigationViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARWorldNavigationDemo")!
    }

    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var spanView : UISlider!
    @IBOutlet weak var longitudeLabel : UILabel!
    @IBOutlet weak var latitudeLabel : UILabel!
    @IBOutlet weak var altitudeLabel : UILabel!

    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Add this location",
                                                message: "",
                                                preferredStyle: .alert)
        // Create the actions
        let action1 = UIAlertAction(title: "Add location", style: .default) { [unowned self] action in
            guard let text = textfield.text else { return }
            self.addLocationTarget(with: text)
        }

        let action2 = UIAlertAction(title: "Saved Locations", style: .default) { [unowned self] action in
            self.goToSavedLocations()
        }

        let action3 = UIAlertAction(title: "AR Scene", style: .default) { [unowned self] action in
            self.goToARScene()
        }

        let action4 = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel")
        }

        alertController.addTextField { alertTextfield in
            alertTextfield.placeholder = "Add name of this location"
            textfield = alertTextfield
        }

        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(action4)

        present(alertController, animated: true, completion: nil)

    }

    var isOriginSet: Bool = false
    var originLocation: CLLocation?
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    var steps: [MKRouteStep] = []
    var annotations: [POIAnnotation] = []
    var annotationColor = UIColor.random
    var sourceAnnotation = MKPointAnnotation()
    var destinationAnnotation = MKPointAnnotation()
    var overlays = [MKOverlay]()

    var realm : Realm!

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async { [unowned self] () in

            self.setupRealm(completion: { [weak self] (realm, error) in
                guard let this = self else { return }
                if let realm = realm {
                    this.realm = realm
                    this.setup()
                }

                if let error = error {
                    print("Could not initialise realm", error)
                }
            })
        }

    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sceneView.session.pause()
        locationManager.stopUpdatingLocation()

    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARWorldNavigationViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap on camera button to see places of interest, then select a place of interest to get more info.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
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
                print("not Determined but Alway autorization")
                return true
            } else if bundle.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                locationManager.requestWhenInUseAuthorization()
                print("not Determined but Alway autorization")
                return true
            } else {
                print("No description provided")
                return false
            }
        }
    }

    func setupRealm(completion : @escaping (Realm?, Error?) -> Void ) {

        // https://realm.io/docs/tutorials/realmtasks/
        if let user = SyncUser.current {
            let configuration = user.configuration()
            Realm.asyncOpen(configuration: configuration, callback: { (realm, error) in
                if let error = error {
                    completion(nil, error)
                } else if let realm = realm {
                    completion(realm, nil)
                } else {
                    completion(nil, nil)
                }
            })

        } else {

            let alertController = UIAlertController(title: "Login to Realm Cloud", message: "Supply a nice username!", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Login",
                                                    style: .default,
                                                    handler: { alert -> Void in

                let MY_INSTANCE_ADDRESS = "projectstem.de1a.cloud.realm.io" // <- update this
                let AUTH_URL = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
                let LOCATIONS_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/locationTargets")!
                let textField = alertController.textFields![0] as UITextField
                let credentials = SyncCredentials.nickname(textField.text!)

                SyncUser.all.forEach({ _, user in user.logOut() })
                SyncUser.logIn(with: credentials, server: AUTH_URL, timeout: 2, onCompletion: { user, error in
                    guard let user = user else {
                        if let error = error { print("❗️ \(error)") }
                        completion(nil, error)
                        return
                    }

                    DispatchQueue.main.async {
                        var configuration = user.configuration(realmURL: LOCATIONS_URL, fullSynchronization: true, enableSSLValidation: false)
                        configuration.objectTypes = [LocationTarget.self]

                        do {
                            let realm = try Realm(configuration: configuration)
                            completion(realm, nil)
                        } catch let error {
                            completion(nil, error)
                        }

                    }
                })
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = "A Name for your user"
            })

            self.present(alertController, animated: true, completion: nil)
        }
    }


    func setup() {

        if ARConfiguration.isSupported {
            if getAutorization() {
                setupMapView()
                setupLocationManager()
            }
        } else {
            print("ARKit is not compatible with this phone.")
            return
        }

    }

    func setupMapView() {
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true

        addTapGesture()
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }

    func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(gesture)
    }

    func annotateMap(with annotation: MKPointAnnotation, name : String, location2D: CLLocationCoordinate2D) {
        annotation.title = name
        annotation.subtitle = "AR World Navigation"
        annotation.coordinate = location2D
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }

    func update(location: CLLocation) {
        let spanValue = CLLocationDegrees(spanView.value)
        let span : MKCoordinateSpan = MKCoordinateSpanMake(spanValue,spanValue)
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let altitude = location.altitude
        let locationPinCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(locationPinCoordinate, span)

        if currentLocation == nil {
            mapView.setRegion(region, animated: true)
            //let placeMark = MKPlacemark(coordinate: locationPinCoordinate)
        }

        currentLocation = location

        annotateMap(with: sourceAnnotation, name: "", location2D: locationPinCoordinate)

        /*
        print("latitude",latitude,
              ",\nlatitude trans", translation.latitudeTranslation,
              ",\nlongitude",longitude,
              ",\nlongitude trans",translation.longitudeTranslation,
              ",\naltitude",altitude,
              ",\naltitude trans",translation.altitudeTranslation,
              ",\nspeed", location.speed)
        */

        if let origin = originLocation {
//            let distance = CLLocationCoordinate2D
//                .intermediaryLocations(from: origin,
//                                       to: location,
//                                       intervalPerNodeInMeters: 0)
            let haversine = origin.coordinate.haversine(to: location.coordinate)
            let distanceEarth = origin.coordinate.distanceEarth(to: location.coordinate)
            let translation = origin.translation(to: location)
            print("\norigin lat", origin.coordinate.latitude,
                  "origin long", origin.coordinate.longitude,
                  "origin alt", origin.altitude,
                  "origin lat", location.coordinate.latitude,
                  "origin long", location.coordinate.longitude,
                  "origin alt", location.altitude,
                  "haversine", haversine,
                  "distance earth", distanceEarth,
                  "translation lat", translation.latitudeTranslation,
                  "translation long", translation.longitudeTranslation,
                  "translation alt", translation.altitudeTranslation)
        }
        DispatchQueue.main.async { [unowned self] () in
            self.longitudeLabel.text = "longitude: \(longitude)"
            self.latitudeLabel.text = "latitude: \(latitude)"
            self.altitudeLabel.text = "altitude: \(altitude)"
        }

    }

    func updateRoute(from current: CLLocation,
                     to destination: CLLocation,
                     transportType: MKDirectionsTransportType) {

        let sourceCoordinates2D = CLLocationCoordinate2DMake(current.coordinate.latitude,
                                                             current.coordinate.longitude)
        annotateMap(with: sourceAnnotation, name: "current", location2D: sourceCoordinates2D)

        let destinationCoordinates2D = CLLocationCoordinate2DMake(destination.coordinate.latitude,
                                                                  destination.coordinate.longitude)
        annotateMap(with: destinationAnnotation, name:"destination", location2D: destinationCoordinates2D)

        let directionRequest = MKDirectionsRequest()

        NavigationService
            .getDirections(from: sourceCoordinates2D,
                           to: destinationCoordinates2D,
                           request: directionRequest,
                           transportType: transportType)
            { [weak self] (route, steps) in
                guard let this = self else { return }

                this.steps.removeAll()
                this.annotations.removeAll()
                for step in steps {
                    this.steps.append(step)
                    let annotation = POIAnnotation(coordinate: step.location.coordinate, name: "N " + step.instructions)
                    this.annotations.append(annotation)
                }
                this.steps.append(contentsOf: steps)

                this.addCircleAnnotations(with: this.annotations)
                //this.addLineAnnotations(with: route)
        }

    }

    func addLineAnnotations(with route: MKRoute) {
        annotationColor = .random

        let rect = route.polyline.boundingMapRect
        let region = MKCoordinateRegionForMapRect(rect)
        mapView.setRegion(region, animated: true)
        mapView.add(route.polyline, level: .aboveRoads)
    }

    func addCircleAnnotations(with annotations: [POIAnnotation]) {
        annotationColor = .random
        mapView.removeOverlays(overlays)

        DispatchQueue.main.async { [weak self] () in
            annotations.forEach { annotation in
            // Step annotations are green, intermediary are blue
                guard let this = self else { return }
                //self.mapView?.addAnnotation(annotation)
                let circleOverlay = MKCircle(center: annotation.coordinate, radius: 0.2)
                this.mapView.add(circleOverlay)
                this.overlays.append(circleOverlay)
            }
        }
    }

    deinit {
        print("AR World Navigation deinit")
    }
}

//MARK: - Segue
extension ARWorldNavigationViewController {

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        switch segueIdentifier {
        case "showLocationsTable":
            let destination = segue.destination as! ARSavedLocationsTableViewController
            destination.realm = realm
        case "showARScene":
            let locationTargets =  realm.objects(LocationTarget.self)
            let destination = segue.destination as! ARLocationTargetsViewController
            if let originLocation = locationTargets.first(where: { $0.isOrigin == true }) {
                let locations = locationTargets.filter({ $0.isOrigin != true })
                destination.originLocation = originLocation.toLocation
                destination.locations = locations.map({ $0.toLocation })
            }
        default:
            break
        }
    }
}

//MARK: - Relam Cloud implemetation
extension ARWorldNavigationViewController {

    // MARK: - Create new LocationTarget for SQL DataBase
    func addLocationTarget(with name : String){

        if navigationController != nil, let location = currentLocation, realm != nil {

            location.reverseGeocode (completion: { [weak self] (placeMarks, errors) -> Void in
                guard let this = self else { return }
                if (errors != nil) {
                    let error = (errors?.localizedDescription ?? "")
                    print("Reverse geocoder failed with error" + error )
                    return
                } else {

                    if let placemark = placeMarks?.first, let realm = this.realm {
                        let addresParcer = AddressParser(applePlacemark: placemark)
                        let addressDict = addresParcer.getAddressDictionary()

                        let address = addressDict.object(forKey: "formattedAddress") as? NSString ?? ""
                        print(address)

                        let locationTarget = LocationTarget(tag: name,
                                                            address: String(address),
                                                            altitude: location.altitude,
                                                            longitude: location.coordinate.longitude,
                                                            latitude: location.coordinate.latitude,
                                                            horizontalAccuracy: location.horizontalAccuracy,
                                                            verticalAccuracy: location.verticalAccuracy,
                                                            course: location.course,
                                                            speed: location.speed,
                                                            timestamp: location.timestamp,
                                                            isOrigin: false)

                        locationTarget.write(to: realm, completion: { [weak self] (error) in
                            guard let this = self else { return }
                            if let error = error {
                                print("could not write to realm:", error)
                            }
                            this.performSegue(withIdentifier: "showLocationsTable", sender: self)
                            print("item saved")
                        })

                    }
                    else {
                        print("No Placemarks Found, problem with the data received from geocoder")
                        return
                    }
                }
            })

        }
    }

    func goToSavedLocations(){
        if navigationController != nil {
            performSegue(withIdentifier: "showLocationsTable", sender: self)
        }
    }

    func goToARScene(){
        if navigationController != nil {
            performSegue(withIdentifier: "showARScene", sender: self)
        }
    }

}


// MARK: - Gestures
extension ARWorldNavigationViewController {
    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        if let map = sender.view as? MKMapView {
            // Get tap point on map
            let touchPoint = sender.location(in: map)

            // Convert map tap point to coordinate
            let coord: CLLocationCoordinate2D = map.convert(touchPoint, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            //update(location: location)
            if let current = currentLocation {
                updateRoute(from: current, to: location, transportType: .walking)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ARWorldNavigationViewController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if isOriginSet == false {
                originLocation = location
                isOriginSet = true
            }
            update(location: location)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined || status != .denied || status != .restricted {
            setupLocationManager()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ARWorldNavigationViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let overlayRenderer: MKOverlayPathRenderer
        if overlay is MKCircle {
            overlayRenderer = MKCircleRenderer(overlay: overlay)
        } else {
            overlayRenderer = MKPolylineRenderer(overlay: overlay)
        }

        overlayRenderer.fillColor = UIColor.black.withAlphaComponent(0.1)
        overlayRenderer.strokeColor = annotationColor
        overlayRenderer.lineWidth = 4

        return overlayRenderer
    }
}

