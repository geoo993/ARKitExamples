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

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARPlanetsDemo")!
    }
    
    var isSolarSystemAdded = false 
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        
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
        
        showHelperAlertIfNeeded()
    }
    
    func getPositionAway(from origin: SCNVector3, with distance: Float) -> SCNVector3 {
        let angle = Float.random(min: 0, max: 360)
        let radian = angle.toRadians
        
        let x = origin.x + (distance * cosf(radian))
        let y = origin.y
        let z = origin.z + (distance * sinf(radian))
        let position = SCNVector3(x, y, z) 
        return position
    }
    
    func addPlanets() {
        guard let camera = sceneView.pointOfView else { return }
        let cameraPosition = SCNScene.currentPositionOf(camera: camera)
        
        let offset : Float = 5
        var direction = SCNVector3.cameraDirection(cameraNode: camera)
        let zPosition = direction.normalize() * offset
        
        let origin = cameraPosition + zPosition
        
        let mercuryDistanceFromSun : CGFloat = 1.2
        let venusDistanceFromSun : CGFloat = 1.4
        let earthDistanceFromSun : CGFloat = 2.0
        let marsDistanceFromSun : CGFloat = 2.8
        let jupiterDistanceFromSun : CGFloat = 3.8 
        let saturnDistanceFromSun : CGFloat = 4.7
        let uranusDistanceFromSun : CGFloat = 5.4
        let neptuneDistanceFromSun : CGFloat = 6.1
        let plutoDistanceFromSun : CGFloat = 6.4
        
        
        addPlanetaryRing(at: origin, with: mercuryDistanceFromSun)
        addPlanetaryRing(at: origin, with: venusDistanceFromSun)
        addPlanetaryRing(at: origin, with: earthDistanceFromSun)
        addPlanetaryRing(at: origin, with: marsDistanceFromSun)
        addPlanetaryRing(at: origin, with: jupiterDistanceFromSun)
        addPlanetaryRing(at: origin, with: saturnDistanceFromSun)
        addPlanetaryRing(at: origin, with: uranusDistanceFromSun)
        addPlanetaryRing(at: origin, with: neptuneDistanceFromSun)
        addPlanetaryRing(at: origin, with: plutoDistanceFromSun)
        
        let sun = addSun(toParent: sceneView.scene.rootNode, at: origin, rotation: 10)
        let mercuryParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 40)
        let venusParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 10)
        let earthParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 24)
        let marsParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 25)
        let jupiterParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 30)
        let saturnParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 45)
        let uranusParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 35)
        let neptuneParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 75)
        let plutoParent = addEmptyNode(toParent: sceneView.scene.rootNode, position: sun.position, rotation: 70)
        
        _ = addMercury(toParent: mercuryParent,at: getPositionAway(from: .zero, with: mercuryDistanceFromSun.toFloat),rotation: 40)
        _ = addVenus(toParent: venusParent, at: getPositionAway(from: .zero, with: venusDistanceFromSun.toFloat), rotation: 80)
        let earth = addEarth(toParent:earthParent,at:getPositionAway(from: .zero, with: earthDistanceFromSun.toFloat),rotation: 25)
        _ = addMoon(toParent: earth, at: SCNVector3(0.0, 0, -0.4), rotation: 100)
        _ = addMars(toParent: marsParent, at: getPositionAway(from: .zero, with: marsDistanceFromSun.toFloat), rotation: 60)
        _ = addJupiter(toParent: jupiterParent,at: getPositionAway(from: .zero, with:jupiterDistanceFromSun.toFloat),rotation: 20)
        _ = addSaturn(toParent: saturnParent, at: getPositionAway(from: .zero, with: saturnDistanceFromSun.toFloat), rotation: 40)
        _ = addUranus(toParent: uranusParent,at: getPositionAway(from: .zero, with: uranusDistanceFromSun.toFloat), rotation: 91)
        _ = addNeptune(toParent: neptuneParent,at:getPositionAway(from: .zero,with:neptuneDistanceFromSun.toFloat), rotation: 112)
        _ = addPluto(toParent: plutoParent, at: getPositionAway(from: .zero, with:plutoDistanceFromSun.toFloat), rotation: 40)
//        
        isSolarSystemAdded = true
    }
    
    func addPlanetaryRing(at origin: SCNVector3, with radius : CGFloat ) {
        let ring = SCNNode(geometry: SCNTorus(ringRadius: radius, pipeRadius: 0.005))
        ring.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
        ring.position = origin
        sceneView.scene.rootNode.addChildNode(ring)
    }
    
    func addSun(toParent parent: SCNNode, at position : SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.8, 
                          position: position, 
                          diffuse: UIImage(named: "sun", in: ARPlanetsViewController.bundle, compatibleWith: nil))
        rotate(planet: node, by: rotation)
        parent.addChildNode(node)
        return node
    }
    
    func addMercury(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.11, 
                          position: position, 
                          diffuse: UIImage(named: "mercury", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func addMoon(toParent parent: SCNNode, at position : SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.05, 
                          position: position, 
                          diffuse: UIImage(named: "moon", in: ARPlanetsViewController.bundle, compatibleWith: nil))
        rotate(planet: node, by: rotation)
        parent.addChildNode(node)
        return node
    }
    
    func addEarth(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.2, 
                          position: position, 
                          diffuse: UIImage(named: "earth_day_map", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          specular: UIImage(named: "earth_specular_map", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          normal: UIImage(named: "earth_normal_map", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          emission: UIImage(named: "earth_clouds", in: ARPlanetsViewController.bundle, compatibleWith: nil))
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func addVenus(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.12, 
                          position: position, 
                          diffuse: UIImage(named: "venus_surface", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          specular: nil,
                          normal: nil,
                          emission: UIImage(named: "venus_atmosphere", in: ARPlanetsViewController.bundle, compatibleWith: nil))
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func addMars(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.07, 
                          position: position, 
                          diffuse: UIImage(named: "mars", in: ARPlanetsViewController.bundle, compatibleWith: nil),
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
                          diffuse: UIImage(named: "jupiter", in: ARPlanetsViewController.bundle, compatibleWith: nil),
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
                          diffuse: UIImage(named: "saturn", in: ARPlanetsViewController.bundle, compatibleWith: nil),
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
                          diffuse: UIImage(named: "uranus", in: ARPlanetsViewController.bundle, compatibleWith: nil),
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
                          diffuse: UIImage(named: "neptune", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        
        return node
    }
    
    func addPluto(toParent parent: SCNNode, at position: SCNVector3, rotation: TimeInterval) -> SCNNode {
        let node = planet(radius: 0.06, 
                          position: position, 
                          diffuse: UIImage(named: "pluto", in: ARPlanetsViewController.bundle, compatibleWith: nil),
                          specular: nil,
                          normal: nil,
                          emission: nil)
        parent.addChildNode(node)
        rotate(planet: node, by: rotation)
        return node
    }
    
    func addEmptyNode(toParent parent: SCNNode, position : SCNVector3, rotation: TimeInterval) -> SCNNode {
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
    
    private func showHelperAlertIfNeeded() {
        let key = "ARPlanetsViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap the screen to show solar system.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    deinit {
        print("AR Planets deinit")
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

// MARK: - Gesture recognizers
extension ARPlanetsViewController {
  
    // called when touches are detected on the screen
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isSolarSystemAdded == false {
            addPlanets()
        }
    }
}
