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
// https://docs.realm.io/cloud/ios-todo-app

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

    var realm : Realm!

    override public func viewDidLoad() {
        super.viewDidLoad()

    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

            //grabData()
        DispatchQueue.main.async { [unowned self] () in

            self.setupRealm(completion: { [weak self] (realm, error) in
                guard let this = self else { return }
                if let realm = realm {
                    this.realm = realm
                    print("we have a new realm")
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

        if let user = SyncUser.current {
            
            RealmObjectServer.setupRealm(with: user,
                                         objectTypes: [LocationTarget.self],
                                         completion: { (realm, error) in
                completion(realm, nil)
            })
        } else {

            let alertController = UIAlertController(title: "Login to Realm Cloud", message: "Supply a nice username!", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Login",
                                                    style: .default,
                                                    handler: { alert -> Void in
                let textField = alertController.textFields![0] as UITextField

                RealmObjectServer.setupRealm(with: textField.text!,
                                             isAdmin: true,
                                             objectTypes: [LocationTarget.self],
                                             completion: { (realm, error) in
                    completion(realm, error)
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
            //let configuration = ARWorldTrackingConfiguration()
            //sceneView.session.run(configuration)

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
            if let destination = segue.destination as? ARSavedLocationsTableViewController {
                destination.realm = realm
            }
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

                        //let streetName =  addressDict.object(forKey: "streetName") as? NSString ?? ""
                        let address = addressDict.object(forKey: "formattedAddress") as? NSString ?? ""
                        print(address)

                        let locationTarget = LocationTarget(tag: name,
                                                            address: String(address),
                                                            altitude: location.altitude,
                                                            longitude: location.coordinate.latitude,
                                                            latitude: location.coordinate.latitude)

                        locationTarget.write(to: realm, completion: { [weak self] (error) in
                            guard let this2 = self else { return }
                            if let error = error {
                                print("could not write to realm:", error)
                            }
                            this2.performSegue(withIdentifier: "showLocationsTable", sender: self)
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

