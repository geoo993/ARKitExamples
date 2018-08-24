//
//  ARPlacesViewController.swift
//  ARPlaces
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

// https://www.raywenderlich.com/146436/augmented-reality-ios-tutorial-location-based-2

import UIKit
import AppCore
import CoreLocation
import MapKit
import SwiftyJSON
import SDWebImage

public class ARPlacesViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARPlacesDemo")!
    }
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var startedLoadingPOIs = false
    fileprivate var places = [Place]()
    fileprivate var arViewController: ARViewController!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func showAR(_ sender: UIButton) {
        arViewController = ARViewController()
        //1
        arViewController.dataSource = self
        
        //2
        arViewController.presenter.maxVisibleAnnotations = 30
        //arViewController.f headingSmoothingFactor = 0.05
        //3
        arViewController.setAnnotations(places)
        
        self.present(arViewController, animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        locationManagerSetup()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARPlacesViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap on camera button to see places of interest, then select a place of interest to get more info.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    func locationManagerSetup() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func annotatePlaces(with json : JSON) {
         //1
        guard let placesArray = json["results"].array else { return }
        
        //2
        for place in placesArray {
            annotatePlace(with: place)
        }
    }
    
    func annotatePlace(with json: JSON) {
        
        // https://developers.google.com/places/web-service/photos
        //3
        if let latitude : CLLocationDegrees = json["geometry"]["location"]["lat"].double,
            let longitude : CLLocationDegrees = json["geometry"]["location"]["lng"].double,
            let reference = json["reference"].string,
            let name = json["name"].string,
            let address = json["vicinity"].string {
            
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            //4
            if let place = Place(location: location, reference: reference, name: name, address: address) { 
                
                let photo = json["photos"][0]
                if let photoReference = photo["photo_reference"].string, let size = photo["width"].int {
                    let placePhotoURL = "\(apiURL)photo?maxwidth=\(size)&photoreference=\(photoReference)&key=\(apiKey)"
                    place.imageURL = placePhotoURL
                }
                
                places.append(place)
                //5
                let annotation = PlaceAnnotation(location: place.location.coordinate, title: place.placeName)
                //6
                DispatchQueue.main.async { [unowned self] () in
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        
    }
    
    func showInfoView(forPlace place: Place) {
        //1
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        //2 
        arViewController.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("AR Places deinit")
    }
}

extension ARPlacesViewController: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //1
        if locations.count > 0 {
            let location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            //2
            if location.horizontalAccuracy < 100 {
                //3
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                
                //1
                if startedLoadingPOIs == false {
                    startedLoadingPOIs = true
                    //2
                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 1000) { [unowned self] placesDict, error in
                        //3
                        if let dict = placesDict {
                            self.annotatePlaces(with: dict)
                        }
                    }
                }
                
            }
        }
    }
}


extension ARPlacesViewController: ARDataSource {
    public func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = PlaceAnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension ARPlacesViewController: AnnotationViewDelegate {
    public func didTouch(annotationView: PlaceAnnotationView) {
        //print("Tapped view for POI: \(annotationView.titleLabel?.text)")
        //1
        if let annotation = annotationView.annotation as? Place {
            //2
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: annotation) { [unowned self] resultDict, error in
                
                //3  
                if let infoDict = resultDict {
                    let result = infoDict["result"]  
                    annotation.phoneNumber = result["formatted_phone_number"].string
                    annotation.website = result["website"].string
                    
                    //4
                    self.showInfoView(forPlace: annotation)
                }
            }
        }
    }
    
    
}

