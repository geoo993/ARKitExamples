//
//  ARWorldNavigationViewController.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-one-fc7cb2fa0150
// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-three-98b1d51e2eac
// https://stackoverflow.com/questions/43097932/realm-sync-swift-example
// https://www.youtube.com/watch?v=fwVeP5BLGtA
// https://www.youtube.com/watch?v=7u9-8e-sSJA
// https://academy.realm.io/posts/marin-todorov-building-reactive-apps-with-realm-episode-1-swift-ios/
// https://www.youtube.com/watch?v=wq4HoJGwtoo
// https://stackoverflow.com/questions/47333208/starting-realm-object-server-on-aws-stalls
// https://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
// https://www.youtube.com/watch?v=OYu3bkOyJY8

import UIKit
import CoreData
import CoreLocation
import MapKit
import ARKit
import SceneKit
import AppCore
import RealmSwift
//import Firebase

public class ARWorldNavigationViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARWorldNavigationDemo")!
    }

    //@IBOutlet weak var sceneView: ARSCNView!
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
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel")
        }
        alertController.addTextField { alertTextfield in
            alertTextfield.placeholder = "Add name of this location"
            textfield = alertTextfield
        }
        alertController.addAction(action1)
        alertController.addAction(action2)

        present(alertController, animated: true, completion: nil)
    }

    let worldCenter = CLLocation(latitude: 0, longitude: 0)
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    var annotation = MKPointAnnotation()

    var notificationToken: NotificationToken?

    override public func viewDidLoad() {
        super.viewDidLoad()

        do {
            RealmObjectServer.realm = try Realm()
        } catch {
            print("Could not initialise realm")
        }
        
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if RealmObjectServer.realm != nil {
            //grabData()
            setup()
        }

        //let configuration = ARWorldTrackingConfiguration()

        //sceneView.session.run(configuration)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
 
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sceneView.session.pause()
        locationManager.stopUpdatingLocation()

        notificationToken?.invalidate()
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARShooterViewController.helperAlert.didShow"
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


    func setup() {
        if ARConfiguration.isSupported {
            locationManager.delegate = self

            if getAutorization() {
                setupMapView()

                //update(location: worldCenter)
                getLocation()

                let gesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
                gesture.numberOfTouchesRequired = 1
                mapView.addGestureRecognizer(gesture)

            }

            //setupScene()

        } else {
            print("ARKit is not compatible with this phone.")
            return
        }

    }

    /*
    func grabData() {
        let databaseRef = Database.database().reference()
        databaseRef.child("locationTargets").observe(.value, with: { (snapShot) in
            for snap in snapShot.children.allObjects as! [DataSnapshot] {
                guard let dictionary = snap.value as? [String : AnyObject] else { return }
                let tag = dictionary["tag"] as! String
                let address = dictionary["address"] as! String
                let altitude = dictionary["altitude"] as! Double
                let longitude = dictionary["longitude"] as! Double
                let latitude = dictionary["latitude"] as! Double

                print(address, tag, altitude, longitude, latitude)
                let locationTarget = LocationTarget(tag: tag,
                                                    address: address,
                                                    altitude: altitude,
                                                    longitude: longitude,
                                                    latitude: latitude)

                do {
                    try RealmObjectServer.realm.write {
                        RealmObjectServer.realm.add(locationTarget)
                    }
                } catch {
                    print("Error updating todo item in Realm \(error)")
                }
            }
        })
    }
    */

    func setupScene() {
        //sceneView.delegate = self
        //sceneView.scene = SCNScene()
        //sceneView.session.delegate = self
    }

    func setupMapView() {
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
    }

    func getLocation () {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }

    func annotateMap(with name : String, location2D: CLLocationCoordinate2D) {
        annotation.title = name
        annotation.coordinate = location2D
        mapView.addAnnotation(annotation)
        //mapView.showAnnotations([annotation], animated: true)
    }

    func update(location: CLLocation) {
        currentLocation = location
        let spanValue = CLLocationDegrees(spanView.value)
        let span : MKCoordinateSpan = MKCoordinateSpanMake(spanValue,spanValue)
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let altitude = location.altitude
        let translation = worldCenter.translation(to: location)
        let locationPinCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(locationPinCoordinate, span)
        mapView.setRegion(region, animated: true)
        //let placeMark = MKPlacemark(coordinate: locationPinCoordinate)

        annotateMap(with: "", location2D: locationPinCoordinate)

        print("latitude",latitude,
              ", latitude trans", translation.latitudeTranslation,
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

    
    deinit {
        print("AR World Navigation deinit")
    }
}

//MARK: - Segue
extension ARWorldNavigationViewController {

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocationsTable" {

        }
    }
}

//MARK: - CoreData SQL DataBase implemetation
extension ARWorldNavigationViewController {

    // MARK: - Create new LocationTarget for SQL DataBase
    func addLocationTarget(with name : String){

        if navigationController != nil, let location = currentLocation, RealmObjectServer.realm != nil {

            location.reverseGeocode (completion: { [unowned self] (placeMarks, errors) -> Void in

                if (errors != nil) {
                    let error = (errors?.localizedDescription ?? "")
                    print("Reverse geocoder failed with error" + error )
                    return
                } else {

                    if let placemark = placeMarks?.first {
                        let addresParcer = AddressParser(applePlacemark: placemark)
                        let addressDict = addresParcer.getAddressDictionary()

                        //let streetName =  addressDict.object(forKey: "streetName") as? NSString ?? ""
                        let address = addressDict.object(forKey: "formattedAddress") as? NSString ?? ""
                        print(address)

                        let locationTarget = LocationTarget(tag: name,
                                                            address: String(address),
                                                            altitude: location.altitude,
                                                            longitude: location.coordinate.latitude,
                                                            latitude: location.coordinate.latitude)
                        self.add(locationTarget: locationTarget)
                    }
                    else {
                        print("No Placemarks Found, problem with the data received from geocoder")
                        return
                    }
                }
            })

        }
    }

    func add( locationTarget item : LocationTarget) {
        item.writeToRealm (completion: { [unowned self] (error) in
            self.performSegue(withIdentifier: "showLocationsTable", sender: self)
            print("item saved")
        })
    }
    func update(locationTarget item : LocationTarget, with other: LocationTarget) {
        item.update(with: other) { (error) in
            print("item updated")
        }
    }

    // MARK: - Delete all LocationTarget in Realm DataBase
    func deleteAllTodoItems() {
        do {
            try RealmObjectServer.realm.write {
                RealmObjectServer.realm.deleteAll()
            }
        } catch {
            print("Error deleting all todo items in Realm \(error)")
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
            update(location: location)
        }
    }

}

// MARK: - ARSCNViewDelegate
extension ARWorldNavigationViewController : ARSCNViewDelegate {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
     
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
     
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
    }
    
}

// MARK: - ARSessionDelegate
extension ARWorldNavigationViewController : ARSessionDelegate {
    
}

// MARK: - CLLocationManagerDelegate
extension ARWorldNavigationViewController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            update(location: location)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined || status != .denied || status != .restricted {
            getLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ARWorldNavigationViewController: MKMapViewDelegate {

}

