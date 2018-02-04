//
//  ARWorldNavigationViewController.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-one-fc7cb2fa0150

import UIKit
import CoreLocation
import MapKit
import ARKit
import SceneKit
import AppCore


public class ARWorldNavigationViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARWorldNavigationDemo")!
    }
    
    var steps: [MKRouteStep] = []
    var destinationLocation: CLLocationCoordinate2D!
    var locationService = LocationService()
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        locationServiceSetup()
        setupScene()
    }
  
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
 
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        locationService.stopUpdatingLocation()
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
    
    func setupScene() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.session.delegate = self
    }
    
    func locationServiceSetup() {
        
        locationService.delegate = self
        let navService = NavigationService()
        
        let cityBar = CLLocation(latitude: 51.528041573315456, longitude:  -0.10065525770187378)
        self.destinationLocation = CLLocationCoordinate2D(latitude: cityBar.coordinate.latitude, 
                                                          longitude: cityBar.coordinate.longitude)
        let request = MKDirectionsRequest()
        if destinationLocation != nil {
            navService
                .getDirections(destinationLocation: destinationLocation, 
                               request: request) { [unowned self] steps in
                for step in steps {
                    self.steps.append(step)
                }
            }
        }
    }
    
    deinit {
        print("AR World Navigation deinit")
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

// MARK: - LocationServiceDelegate
extension ARWorldNavigationViewController: LocationServiceDelegate {
    public func tracingLocation(currentLocation: CLLocation) {
        print(currentLocation)
    }
    
    public func tracingLocationDidFailWithError(error: Error) {
        
    }
    
}


// MARK: - Gestures
extension ARWorldNavigationViewController {
    
   
}
