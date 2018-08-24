//
//  ARDrawingViewController.swift
//  ARDrawing
//
//  Created by GEORGE QUENTIN on 27/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARDrawingViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARDrawingDemo")!
    }
    
    var nextColor = false
    var color = UIColor.random
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton : UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.antialiasingMode = .multisampling4X
      
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWorldOrigin]
        
        self.sceneView.autoenablesDefaultLighting = true

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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
    
    func drawShape(with name: String, at position : SCNVector3) {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
        sphereNode.position = position
        sphereNode.name = name
        sphereNode.geometry?.firstMaterial?.diffuse.contents = self.color
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARDrawingViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap and hold the draw button to draw in the scene.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    deinit {
        print("AR Drawing deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension ARDrawingViewController: ARSCNViewDelegate {    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // called 60 times per second (60 fps)
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
      
        // position is a combination of orientation and location
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33) // in the third column in the matrix
        let location = SCNVector3(transform.m41, transform.m42, transform.m43) // the translation in fourth column in the matrix 
        let currentPositionOfCamera = orientation + location
        
        DispatchQueue.main.async { [unowned self] () in
            if self.drawButton.isHighlighted {
                self.drawShape(with: "Sphere", at: currentPositionOfCamera)
                self.nextColor = true
            } else {
                if self.nextColor {
                    self.color = UIColor.random
                    self.nextColor = false
                }
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "Pointer" {
                        node.removeFromParentNode()
                    }
                })
                self.drawShape(with: "Pointer", at: currentPositionOfCamera)
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
