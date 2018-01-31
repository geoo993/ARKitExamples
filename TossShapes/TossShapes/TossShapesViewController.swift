//
//  TossShapeViewController.swift
//  TossShapes
//
//  Created by GEORGE QUENTIN on 31/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class TossShapesViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.TossShapesDemo")!
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var planeDetectedLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        
        planeDetectedLabel.isHidden = true
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "TossShapesViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap button to toss shapes around.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    func spawnShapeOnPlane(at testResult: ARHitTestResult) {
        
        let worldPosition = testResult.worldTransform.columns.3
        
        let geometryNode = NodeGenerator
            .generateRandomShape(with: .random,
                                 at: SCNVector3(0,0,0), 
                                 with: false)
        geometryNode.position = SCNVector3(x: worldPosition.x, 
                                           y: worldPosition.y + geometryNode.boundingSphere.radius, 
                                           z: worldPosition.z)
        sceneView.scene.rootNode.addChildNode(geometryNode)
        
    }
    
    func spawnShape() {
        if let camera = self.sceneView.pointOfView {
            
            let dir = SCNVector3.calculateCameraDirection(cameraNode: camera)
            let pos = SCNVector3.pointInFrontOfPoint(point: camera.position, direction:dir, distance: 1.8)
            
            let geometryNode = NodeGenerator
                .generateRandomShapeInFrontOf(node: camera, 
                                              color: .random, 
                                              at: SCNVector3(x: 0, y: -0.03, z: -1),
                                              with: true)
            
            geometryNode.position = pos
            geometryNode.orientation = camera.orientation
            applyForce(to: geometryNode, inDirection: dir)
            self.sceneView.scene.rootNode.addChildNode(geometryNode)
        }
    }
    
    func applyForce(to node: SCNNode, inDirection: SCNVector3) {
        
        let power = Float.random(min: 4.0, max: 10)
        let lift = Float.random(min: 0.5, max: 5.0)
        
        var direction = inDirection
        direction = direction.normalize() * power
        let force = SCNVector3(x: direction.x, y: direction.y + lift , z: direction.z)
        
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        node.physicsBody?.applyForce(force, at: position, asImpulse: true)
    }
    
    deinit {
        print("Toss Shapes deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension TossShapesViewController : ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async { [unowned self] () in
            self.planeDetectedLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] () in
                self.planeDetectedLabel.isHidden = true
            }
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - Gesture recognisers
extension TossShapesViewController {  
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
            
            if let hitResult = results.first {
                spawnShapeOnPlane(at: hitResult)
            }else {                
                spawnShape()
            }
        }
        
    }
}

