//
//  ARLocationTargetsViewController.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 24/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ARKit
import AppCore

public class ARLocationTargetsViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!

    var locations: [CLLocation] = []  // locations given in the table view
    var updatedLocations: [CLLocation] = []
    var nodes: [LocationTargetNode] = []
    var originLocation: CLLocation!
    let locationManager = CLLocationManager()
    var locationService = LocationService()
    var updateNodes: Bool = false
    private var locationUpdates: Int = 0 {
        didSet {
            if locationUpdates >= 4 {
                updateNodes = false
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.session.delegate = self

        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

        sceneView.autoenablesDefaultLighting = true

        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupARConfiguration()
        setupLocationService()
        addTapGesture()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
        locationManager.stopUpdatingLocation()
    }

    func setupARConfiguration() {

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.worldAlignment = .gravityAndHeading
        //configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func setupLocationService() {
        locationService = LocationService(manager: locationManager)
        locationService.delegate = self
    }

    func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(gesture)
    }

    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        updateNodes = true
        if (sender.view as? ARSCNView) != nil, locationUpdates == 0 {
            for location in locations {
                addSphere(to: location)
            }
        }
    }

    // For intermediary locations - CLLocation - add sphere

    func addSphere(to location: CLLocation) {
        let locationTransform = MatrixHelper
            .transformMatrix(for: matrix_identity_float4x4, from: originLocation, to: location)

        let anchor = ARAnchor(transform: locationTransform)
        let sphere = LocationTargetNode(title: "Sphere", location: location)
        sphere.addSphere(with: 0.25, and: .random)
        sphere.location = location
        sceneView.session.add(anchor: anchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        let distance = sphere.location.distance(from: originLocation)
        setTransform(of: sphere, transform: locationTransform, distance: distance)


        print("\norigin lat", originLocation.coordinate.latitude,
              "origin long", originLocation.coordinate.longitude,
              "origin alt", originLocation.altitude,
              "dest lat", location.coordinate.latitude,
              "dest long", location.coordinate.longitude,
              "dest alt", location.altitude)

        nodes.append(sphere)
    }

    private func updateLocationTargetsPosition() {
        if updateNodes {
            locationUpdates += 1
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            if updatedLocations.count > 0 {
                originLocation = CLLocation.bestLocationEstimate(from: updatedLocations)
                for baseNode in nodes {
                    let locationTransform = MatrixHelper
                        .transformMatrix(for: matrix_identity_float4x4,
                                         from: originLocation, to: baseNode.location)
                    let distance = baseNode.location.distance(from: originLocation)
                    setTransform(of: baseNode, transform: locationTransform, distance: distance)
                }
            }
            SCNTransaction.commit()
        }

    }

    func setTransform(of node: LocationTargetNode, transform: simd_float4x4, distance: CLLocationDistance) {
        DispatchQueue.main.async {
            let scale: Float = 10.0//100 / Float(distance)
            node.scale = SCNVector3(x: scale, y: scale, z: scale)
            node.anchor = ARAnchor(transform: transform)
            node.position = transform.position.toVector3
        }
    }

    deinit {
        print("AR Location Targets deinit")
    }
}


// MARK: - ARSCNViewDelegate
extension ARLocationTargetsViewController : ARSCNViewDelegate {

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

    public func session(_ session: ARSession, didFailWithError error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }

    public func sessionWasInterrupted(_ session: ARSession) {
        presentMessage(title: "Error", message: "Session Interuption")
    }

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            print("ready")
        case .notAvailable:
            print("wait")
        case .limited(let reason):
            print("limited tracking state: \(reason)")
        }
    }

}

// MARK: - ARSessionDelegate
extension ARLocationTargetsViewController : ARSessionDelegate {

}

extension ARLocationTargetsViewController: LocationServiceDelegate {

    public func trackingLocation(of currentLocation: CLLocation) {
        if currentLocation.horizontalAccuracy <= 65.0 {
            updatedLocations.append(currentLocation)
            updateLocationTargetsPosition()
        }

    }

    public func trackingLocationDidFail(with error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
}

extension ARLocationTargetsViewController {

    func presentMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

