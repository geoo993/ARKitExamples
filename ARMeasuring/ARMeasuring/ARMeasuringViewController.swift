//
//  ARMeasuringViewController.swift
//  ARMeasuring
//
//  Created by GEORGE QUENTIN on 29/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore
import Chameleon

public class ARMeasuringViewController: UIViewController {

    var startingPosition : SCNNode?
    var endPosition : SCNNode?
    let distanceFromCamera : Float = -1
    var distanceTraveled : Float = -1
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        updateLabelsColors(with: .white,alpha: 1.0)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
   
    func renderText(with distance: Float, at position: SCNVector3, with color: UIColor) {
        let textNode = SCNNode(geometry: SCNText(string: "\(distance)m", extrusionDepth: 0.5))
        textNode.geometry?.firstMaterial?.diffuse.contents = color
        textNode.position = position
        textNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func updateLabelsColors(with color : UIColor, alpha: CGFloat) {
        let constrastColor = ContrastColorOf(color, returnFlat: true)
        distanceLabel.backgroundColor = color.withAlphaComponent(alpha)
        xLabel.backgroundColor = color.withAlphaComponent(alpha)
        yLabel.backgroundColor = color.withAlphaComponent(alpha)
        zLabel.backgroundColor = color.withAlphaComponent(alpha)
        
        distanceLabel.textColor = constrastColor
        xLabel.textColor = constrastColor
        yLabel.textColor = constrastColor
        zLabel.textColor = constrastColor
    }
}

// MARK: - Gestures Recognizer
extension ARMeasuringViewController {  
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let _ = startingPosition, 
            let end = endPosition, 
            let color = endPosition?.geometry?.firstMaterial?.diffuse.contents as? UIColor {
            //startingPosition?.removeFromParentNode()
            
            renderText(with: distanceTraveled, at: end.position, with: color)
            
            startingPosition = nil
            endPosition = nil
            return 
        }
        
        if let camerafront = sceneView.camerafront(by: distanceFromCamera) {

            let color = UIColor.random
            let startnode = SCNNode.createSphere(with: "", radius: 0.01, at: camerafront, color: color)
            let endnode = SCNNode.createSphere(with: "", radius: 0.01, at: camerafront, color: color)
            sceneView.scene.rootNode.addChildNode(startnode)
            sceneView.scene.rootNode.addChildNode(endnode)
            
            startingPosition = startnode
            endPosition = endnode
            updateLabelsColors(with: color,alpha: 0.6)
        }
        
    }
}
    // MARK: - ARSCNViewDelegate
extension ARMeasuringViewController: ARSCNViewDelegate {    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let startingPosition = startingPosition,
            let pointOfView = sceneView.pointOfView {
            let transform = pointOfView.transform
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let positionTraveled = location - startingPosition.position
            distanceTraveled = location.distance(vector: startingPosition.position)
            
            DispatchQueue.main.async { [weak self] () in
                guard let this = self else { return }
                this.xLabel.text = String(format:"%.2f", positionTraveled.x ) + "m"
                this.yLabel.text = String(format:"%.2f", positionTraveled.y ) + "m"
                this.zLabel.text = String(format:"%.2f", positionTraveled.z ) + "m"
                this.distanceLabel.text = String(format:"%.2f", this.distanceTraveled ) + "m"
                
                if let camerafront = this.sceneView.camerafront(by: this.distanceFromCamera) {
                    this.endPosition?.simdTransform = camerafront
                }
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
