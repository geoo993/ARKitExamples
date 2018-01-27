//
//  ARPlanetsViewController.swift
//  ARPlanets
//
//  Created by GEORGE QUENTIN on 27/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://www.solarsystemscope.com/textures

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARPlanetsViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let sun = addSun(toParent: sceneView.scene.rootNode, at: SCNVector3(0, 0, -1.5), rotation: 10)
        let earthParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 14)
        let venusParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 10)
        let marsParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 25)
        let jupiterParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 30)
        let saturnParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 45)
        let uranusParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 35)
        let neptuneParent = addAmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 75)
        
        let earth = addEarth(toParent: earthParent, at: SCNVector3(2.0, 0, 0.0), rotation: 25)
        _ = addMoon(toParent: earth, at: SCNVector3(0.0, 0, -0.4), rotation: 100)
        _ = addVenus(toParent: venusParent, at: SCNVector3(1.4, 0, 0.0), rotation: 80)
        _ = addMars(toParent: marsParent, at: SCNVector3(2.8, 0, 0.0), rotation: 60)
        _ = addJupiter(toParent: jupiterParent, at: SCNVector3(3.8, 0, 0.0), rotation: 20)
        _ = addSaturn(toParent: saturnParent, at: SCNVector3(4.7, 0, 0.0), rotation: 40)
        _ = addUranus(toParent: uranusParent, at: SCNVector3(5.3, 0, 0.0), rotation: 91)
        _ = addNeptune(toParent: neptuneParent, at: SCNVector3(5.9, 0, 0.0), rotation: 112)
        
    }
    
    func addSun(toParent parent: SCNNode, at position : SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.8, position: position, diffuse: UIImage(named: "sun"))
        rotate(planet: node, by: rotation)
        parent.addChildNode(node)
        return node
    }
    
    func addMoon(toParent parent: SCNNode, at position : SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.05, position: position, diffuse: UIImage(named: "moon"))
        rotate(planet: node, by: rotation)
        parent.addChildNode(node)
        return node
    }
    
    func addEarth(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.2, 
                          position: position, 
                          diffuse: UIImage(named: "earth_day_map"),
                          specular: UIImage(named: "earth_specular_map"),
                          normal: UIImage(named: "earth_normal_map"),
                          emission: UIImage(named: "earth_clouds"))
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func addVenus(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.12, 
                          position: position, 
                          diffuse: UIImage(named: "venus_surface"),
                          specular: nil,
                          normal: nil,
                          emission: UIImage(named: "venus_atmosphere"))
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func addMars(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.07, 
                          position: position, 
                          diffuse: UIImage(named: "mars"),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    
    func addJupiter(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.49, 
                          position: position, 
                          diffuse: UIImage(named: "jupiter"),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    
    func addSaturn(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.41, 
                          position: position, 
                          diffuse: UIImage(named: "saturn"),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        
        return node
    }
    
    func addUranus(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.3, 
                          position: position, 
                          diffuse: UIImage(named: "uranus"),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        
        return node
    }
    
    func addNeptune(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.32, 
                          position: position, 
                          diffuse: UIImage(named: "neptune"),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        
        return node
    }
    
    func addAmptyNode(toParent parent: SCNNode, position : SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = SCNNode()
        node.position = position
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func planet (radius: CGFloat, 
                 position : SCNVector3,
                 diffuse: UIImage?,
                 specular: UIImage? = nil,
                 normal: UIImage? = nil,
                 emission: UIImage? = nil) -> SCNNode {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.geometry?.firstMaterial?.diffuse.contents = diffuse
        node.geometry?.firstMaterial?.specular.contents = specular
        node.geometry?.firstMaterial?.normal.contents = normal
        node.geometry?.firstMaterial?.emission.contents = emission
        node.position = position
        return node
    }
    
    func rotate(planet: SCNNode, by rotation: TimeInterval ) {
        let action = SCNAction.rotateForeverBy(x:0, y: CGFloat(360).toRadians, z: 0, duration: rotation)
        planet.runAction(action)
    }
    
}

// MARK: - ARSCNViewDelegate
extension ARPlanetsViewController : ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    // render scene 60 frames per seconds
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
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
