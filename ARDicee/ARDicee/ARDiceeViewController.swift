//
//  ARDiceeViewController.swift
//  ARDicee
//
//  Created by GEORGE QUENTIN on 31/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARDiceeViewController: UIViewController {

    fileprivate var dices = [SCNNode]()
    fileprivate var planes: [String : SCNNode] = [:]
    let planeColor = UIColor.random.withAlphaComponent(0.8) 
    var planeImagePath: String? {
        return SCNScene.scnPath(from: ARDiceeViewController.bundle, scnassets: "art", fileName: "grid", ofType: "png")
    }
    
    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARDiceeDemo")!
    }
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func rollDices(_ sender : UIButton) {
        rollAll()
    }
    
    @IBAction func removeDices(_ sender : UIButton) {
        removeAll()
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWorldOrigin]
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Enable lighting
        sceneView.autoenablesDefaultLighting = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // setting plane detection to horizontal so that we are able to detect horizontal planes.
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK - Dice methods
    
    // create plane using planeAnchor detected.
    func createPlane(with planeAnchor : ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.005, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: -0.005, z: planeAnchor.center.z)
        addDiffuseMaterial(to: planeNode)
        
        return planeNode
    }
    
    // create plane using planeAnchor new size.
    func update(planeNode: SCNNode, with planeAnchor : ARPlaneAnchor) {
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.005, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        planeNode.geometry = plane
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: -0.005, z: planeAnchor.center.z)
        addDiffuseMaterial(to: planeNode)
    }
    
    func addDiffuseMaterial(to plane: SCNNode) {
        if let imagePath = planeImagePath {
            plane.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imagePath) ?? planeColor
        }else {
            plane.geometry?.firstMaterial?.diffuse.contents = planeColor
        }
    }
    
    func addDice(at position: simd_float4) {
        
        // Create a new scene
        if let scene = SCNScene.loadScene(from: ARDiceeViewController.bundle, scnassets: "art", name: "dice"), 
           let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(x: position.x, 
                                           y: position.y + diceNode.boundingSphere.radius, 
                                           z: position.z)
            dices.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    func roll(dice: SCNNode) {
        if dices.contains(dice) {
            let randomX = CGFloat.random(min: -180, max: 180) * 5
            let randomZ = CGFloat.random(min: -180, max: 180) * 5
            dice.runAction(SCNAction
                .rotateBy(x: randomX.toRadians, 
                          y: 0, 
                          z: randomZ.toRadians, 
                          duration: 0.5))
        }
    }
    
    func rollAll() {
        
        if dices.isEmpty {
            return
        }
        
        for dice in dices {
            roll(dice: dice)
        }
    }
    
    func removeAll() {
        
        if dices.isEmpty {
            return
        }
        
        for dice in dices {
            dice.removeFromParentNode()
        }
        dices.removeAll()
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARDiceeViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect horizontal plane and Tap on plane to add dices.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    deinit {
        print("AR Dicee deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension ARDiceeViewController: ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // this is a delegate method which comes from ARSCNViewDelegate, and this method is called when a horizontal plane is detected.
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // anchors can be of many types, as we are just dealing with horizontal plane detection we need to downcast anchor to ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
        // creating a plane with the help of dimentions we got using plane anchor.
        let key = planeAnchor.identifier.uuidString
        let planeNode = createPlane(with: planeAnchor)
        node.addChildNode(planeNode)
        planes[key] = planeNode
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // updating te plane with the new dimentions taken from plane anchor.
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            update(planeNode: existingPlane, with: planeAnchor)
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

// MARK: - Touches in view
extension ARDiceeViewController { 
    
    // called when touches are detected on the screen
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            // gives us the location of where we touched on the 2D screen.
            let touchLocation = touch.location(in: sceneView)
            
            // hitTest is performed to get the 3D coordinates corresponding to the 2D coordinates that we got from touching the screen.
            // That 3d coordinate will only be considered when it is on the existing plane that we detected.
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // if we have got some results using the hitTest then do the next statement
            if let hitResult = results.first {
                addDice(at: hitResult.worldTransform.columns.3)
            }
        }
    }
    
}

// MARK: - Shake Motion 
extension ARDiceeViewController {  
    
    public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
}

