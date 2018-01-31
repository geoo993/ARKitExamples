//
//  ARPortalViewController.swift
//  ARPortal
//
//  Created by GEORGE QUENTIN on 29/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARPortalViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARPortalDemo")!
    }
    
    let skyBoxName = ["petrolstation", "porchfold"]
    var skyboxIndex = 1
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var planeDetectedLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        planeDetectedLabel.isHidden = true
        
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
    
    func resetScene() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    func addPortal(with hitTestResult: ARHitTestResult) {
        
        if let scene = SCNScene.loadScene(from: ARPortalViewController.bundle, scnassets: "art", name: "portal"),
            let node = scene.rootNode.childNode(withName: "portal", recursively: false){
            
            let transform = hitTestResult.worldTransform 
            let thirdColumn = transform.columns.3
            let anchorPosition = SCNVector3(x: thirdColumn.x, y: thirdColumn.y, z: thirdColumn.z)
            node.position = anchorPosition
            sceneView.scene.rootNode.addChildNode(node)
            
            skyboxIndex = Int.random(min: 0, max: skyBoxName.count - 1)
            let skyBox = skyBoxName[skyboxIndex]
            
            // cut front image by (imagsize * 0.375) (which is half of 0.625 of the side doors) 
            addPlane(nodeName: "backWall", portal: node, imageName: skyBox+"_bk.jpg")
            addPlane(nodeName: "sideWallA", portal: node, imageName: skyBox+"_lf.jpg")
            addPlane(nodeName: "sideWallB", portal: node, imageName: skyBox+"_rt.jpg")
            addPlane(nodeName: "sideDoorA", portal: node, imageName: skyBox+"_ftA.jpg")
            addPlane(nodeName: "sideDoorB", portal: node, imageName: skyBox+"_ftB.jpg")
            addPlane(nodeName: "roof", portal: node, imageName: skyBox+"_up.jpg")
            addPlane(nodeName: "floor", portal: node, imageName: skyBox+"_dn.jpg")
        }
    }
    
    func addPlane(nodeName: String, portal: SCNNode, imageName: String) {
        let childNode = portal.childNode(withName: nodeName, recursively: true)
        let image = UIImage(named: "art.scnassets/\(imageName)", in: ARPortalViewController.bundle, compatibleWith: nil)
        childNode?.geometry?.firstMaterial?.diffuse.contents = image
        
        childNode?.renderingOrder = 200
        if let mask = childNode?.childNode(withName: "mask", recursively: false) {
            // for something to be translucent, it depends heavily on rendering order
            // the mask has a default rendering order of 0, which is going to be render way before the childNode will
            mask.geometry?.firstMaterial?.transparency = 0.000001 // allmost completely transparent
        }
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARPortalViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect horizontal plane and tap to add portal.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    deinit {
        print("AR Portal deinit")
    }
 
}

// MARK: - ARSCNViewDelegate
extension ARPortalViewController: ARSCNViewDelegate {
    
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
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
       
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

// MARK: - gesture recognizer
extension ARPortalViewController {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = hitTest.first {
                resetScene()
                addPortal(with: hitResult)
            }
        }
    }

}
