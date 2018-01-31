//
//  ARShooterViewController.swift
//  ARShooter
//
//  Created by GEORGE QUENTIN on 30/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARShooterViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARShooterDemo")!
    }
    
    var target : SCNNode?
    var projectile : SCNNode?
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func addTargets(_ sender : UIButton) {
        
        if let camera = sceneView.pointOfView {
            let color = UIColor.random
            addEgg(from: camera, color: color, xOffset: 5, zOffset: 40)
            addEgg(from: camera, color: color, xOffset: 0, zOffset: 40)
            addEgg(from: camera, color: color, xOffset: -5, zOffset: 40)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        registerGestures()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
   
    func addEgg(from camera : SCNNode, color: UIColor, xOffset: Float, zOffset : Float) {
        
        //var direction = SCNVector3.calculateCameraDirection(cameraNode: camera)
        var direction = SCNVector3.cameraDirection(cameraNode: camera)
        let zPosition = direction.normalize() * zOffset
        let xPosition = (camera.worldRight * xOffset)
        
        if let scene = SCNScene.loadScene(from: ARShooterViewController.bundle, scnassets: "art", name: "egg"),
            let node = scene.rootNode.childNode(withName: "egg", recursively: false){
            node.geometry?.firstMaterial?.diffuse.contents = color
            node.orientation = camera.orientation
            node.position = xPosition + zPosition
            
            let shape = SCNPhysicsShape(node: node, options: [SCNPhysicsShape.Option.keepAsCompound : true])
            node.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
            node.physicsBody?.categoryBitMask = CollisionTypes.target.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.projectile.rawValue
            sceneView.scene.rootNode.addChildNode(node)
        }
    }

    func shootPojectile(at position: SCNVector3, orientation: SCNQuaternion) {
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.random
        bullet.position = position
        bullet.orientation = orientation
        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.categoryBitMask = CollisionTypes.projectile.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionTypes.target.rawValue
        applyForce(to: bullet, direction: bullet.worldFront, power: 50.0)
        sceneView.scene.rootNode.addChildNode(bullet)
        
        let sequenceActions = SCNAction.sequence( [SCNAction.wait(duration: 5.0), SCNAction.removeFromParentNode()]) 
        bullet.runAction( sequenceActions )
    }
    
    func applyForce(to node: SCNNode, direction: SCNVector3, power: Float, lift: Float = 0) {
        
        var nodeDirection = direction * power
        nodeDirection = nodeDirection.normalize() * power
        let force = SCNVector3(x: nodeDirection.x, y: nodeDirection.y + lift, z: nodeDirection.z)
        
        node.physicsBody?.applyForce(force, asImpulse: true)
    }
    
    deinit {
        print("AR Shooter deinit")
    }
    
}


// MARK: - ARSCNViewDelegate
extension ARShooterViewController: ARSCNViewDelegate {     
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
extension ARShooterViewController: SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let mask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        if CollisionTypes(rawValue: mask) == [CollisionTypes.projectile, CollisionTypes.target] {
        
            if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.target.rawValue {
                target = contact.nodeA
                projectile = contact.nodeB
            } else if contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.target.rawValue {
                target = contact.nodeB
                projectile = contact.nodeA
            }
        }
        
        if let confetti =  SCNParticleSystem(named: "art.scnassets/confetti.scnp", inDirectory: nil),
            let target = target,
            let projectile = projectile {        
            
            confetti.loops = false
            confetti.particleLifeSpan = 4.0
            confetti.emitterShape = target.geometry
            
            let confettiNode = SCNNode()
            confettiNode.position = contact.contactPoint
            confettiNode.addParticleSystem(confetti)
            sceneView.scene.rootNode.addChildNode(confettiNode)
            
            target.removeFromParentNode()
            projectile.removeFromParentNode()
        }
        
    }
}

// MARK: - gesture recognizer
extension ARShooterViewController {
    
    func registerGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let sceneView = sender.view as? ARSCNView,
            let camera = sceneView.pointOfView {
            let orientation = SCNVector3.cameraDirection(cameraNode: camera)
            let location = SCNVector3.cameraTranslation(cameraNode: camera)
            let position = orientation + location
            shootPojectile(at: position, orientation: camera.orientation)
        }
    }
    
}

