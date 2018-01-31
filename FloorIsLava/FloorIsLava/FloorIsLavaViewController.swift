//
//  FloorIsLavaViewController.swift
//  FloorIsLava
//
//  Created by GEORGE QUENTIN on 28/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class FloorIsLavaViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.FloorIsLavaDemo")!
    }
    
    let grid = UIImage(named:"art.scnassets/grid.png")
    let lava = UIImage(named:"lava")
    fileprivate var planes: [String : SCNNode] = [:]
    
    var bottomNode : SCNNode!
    
    @IBOutlet var sceneView: ARSCNView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        
        configureWorldBottom()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.run(configuration)
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func tapScreen() {
        if let camera = self.sceneView.pointOfView {
            let cube = NodeGenerator.generateRandomShapeInFrontOf(node: camera, 
                                                                  color: .random, 
                                                                  at: SCNVector3(x: 0, y: 0, z: -1), 
                                                                  with: true)
                //NodeGenerator.generateCubeInFrontOf(node: camera, physics: true, color: .random)
            sceneView.scene.rootNode.addChildNode(cube)
        }
    }
    // MARK: - Private Methods
    
    private func showHelperAlertIfNeeded() {
        let key = "PlaneMapperViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Look around to identify horizontal planes. Tap to drop a cube into the world.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    private func configureWorldBottom() {
        bottomNode = SCNNode()
        let physicsBody = SCNPhysicsBody.static()
        physicsBody.categoryBitMask = CollisionTypes.bottom.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.shape.rawValue
        bottomNode.physicsBody = physicsBody
        sceneView.scene.rootNode.addChildNode(bottomNode)
    }
    
    deinit {
        print("Floor is Lava deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension FloorIsLavaViewController: ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        let planeNode = NodeGenerator.generatePlaneFrom(planeAnchor: planeAnchor, physics: true, hidden: false)
        node.addChildNode(planeNode)
        planes[key] = planeNode
        
        if (bottomNode != nil) {
            bottomNode.removeFromParentNode()
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            NodeGenerator.update(planeNode: existingPlane, from: planeAnchor, hidden: false)
            if (bottomNode != nil) {
                bottomNode.removeFromParentNode()
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // this function removes any new plane anchor found, as we already have a planeAnchor in the scene
        // or when more than one anchor is added, it is removed and this function is called
        // we need t deal with the plane anchors that have been removed

        let key = planeAnchor.identifier.uuidString
        if let existingPlane = planes[key] {
            existingPlane.removeFromParentNode()
            planes.removeValue(forKey: key)
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

extension FloorIsLavaViewController : SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let mask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask

        if CollisionTypes(rawValue: mask) == [CollisionTypes.bottom, CollisionTypes.shape] {
            if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.bottom.rawValue {
                contact.nodeB.removeFromParentNode()
            } else {
                contact.nodeA.removeFromParentNode()
            }
        }
    }
}

