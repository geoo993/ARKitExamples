//
//  ARHoopsViewController.swift
//  ARHoops
//
//  Created by GEORGE QUENTIN on 30/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARHoopsViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARHoopsDemo")!
    }

    var basketBallNumber = 1
    var scoreCount = 0
    var power : Float = 0
    var lift : Float = 0
    var restitution : CGFloat = 0.3
    
    var timer = Timer()
    var basketAdded : Bool {
        return self.sceneView.scene.rootNode.childNode(withName: "basket", recursively: false) != nil
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var planeDetectedLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        planeDetectedLabel.isHidden = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true

        sceneView.scene.physicsWorld.contactDelegate = self

        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        registerGestures()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
//        timer.stop()
    }
    
    
    func addBasketballCoart(with hitTestResult: ARHitTestResult) {
        
        if let scene = SCNScene.loadScene(from: ARHoopsViewController.bundle, scnassets: "art", name: "basketball"),
            let court = scene.rootNode.childNode(withName: "basket", recursively: false),
            let score = scene.rootNode.childNode(withName: "score", recursively: true) {

            let transform = hitTestResult.worldTransform 
            let thirdColumn = transform.columns.3
            let anchorPosition = SCNVector3(x: thirdColumn.x, y: thirdColumn.y, z: thirdColumn.z)
            court.position = anchorPosition
            
            let options : [SCNPhysicsShape.Option : Any] = [SCNPhysicsShape.Option.keepAsCompound : true,
                           SCNPhysicsShape.Option.type :  SCNPhysicsShape.ShapeType.concavePolyhedron ]
            let coartShape = SCNPhysicsShape(node: court, options: options)
            court.physicsBody = SCNPhysicsBody(type: .static, shape: coartShape)
            sceneView.scene.rootNode.addChildNode(court)

            score.physicsBody = SCNPhysicsBody.static()
            score.physicsBody?.categoryBitMask = CollisionTypes.target.rawValue
            score.physicsBody?.contactTestBitMask = CollisionTypes.projectile.rawValue
            score.physicsBody?.collisionBitMask = 0
            court.addChildNode(score)
        }
    }
    
    func shootBall() {
        
        removeEveryOtherBall()
        
        if let camera = sceneView.pointOfView {
            let transform = camera.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let translation = SCNVector3(transform.m41, transform.m42, transform.m43)
            let currentPositionOfCamera = orientation + translation
            
            let image = UIImage(named: "basketball-texture", in: ARHoopsViewController.bundle, compatibleWith: nil)
            let ball = BasketBall(name: "Basketball", radius: 0.2, tag: basketBallNumber)
            ball.name = "Basketball"
            ball.geometry?.firstMaterial?.diffuse.contents = image
            ball.geometry?.firstMaterial?.isDoubleSided = true
            ball.position = currentPositionOfCamera
            ball.orientation = camera.orientation
            
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball, options: nil))
            body.restitution = restitution
            ball.physicsBody = body
            ball.physicsBody?.categoryBitMask = CollisionTypes.projectile.rawValue
            ball.physicsBody?.contactTestBitMask = CollisionTypes.target.rawValue

            //let dir = SCNVector3(orientation.x, orientation.y, orientation.z)
            let dir = SCNVector3.calculateCameraDirection(cameraNode: camera)
            
            applyForce(to: ball, direction: dir)
            sceneView.scene.rootNode.addChildNode(ball)
        }
    }
    
    func applyForce(to node: SCNNode, direction: SCNVector3) {
        
        //power = Float.random(min: 5.0, max: 10.0)
        //lift = Float.random(min: 1.0, max: 5.0)
      
        var ballDirection = direction
        ballDirection = ballDirection.normalize() * power
        let force = SCNVector3(x: ballDirection.x, y: ballDirection.y + lift, z: ballDirection.z)
        
        //let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        node.physicsBody?.applyForce(force, asImpulse: true)
        
        self.power = 1.0
        self.lift = 0.1
    }
    
    func removeEveryOtherBall () {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "Basketball" {
                node.removeFromParentNode()
            }
        }
    }

    public func didBeginColliding(with basketBall: SCNNode) {
        print("did beging collide now update the basketBallNumber")

        basketBallNumber += 1
        updateScore()
    }

    public func didEndColliding(with basketBall: SCNNode) {
        print("did end collide now update the score")

    }

    public func updateScore() {
        DispatchQueue.main.async { [unowned self] () in
            self.scoreCount += 1
            self.scoreLabel.text = "\(self.scoreCount)"
        }
    }

    
    private func showHelperAlertIfNeeded() {
        let key = "ARHoopsViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect horizontal plane and add basketball coart. Tap hold on screen to throw basketballs.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    deinit {
        print("AR Hoops deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension ARHoopsViewController: ARSCNViewDelegate {     
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
extension ARHoopsViewController {
    
    func registerGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.1
        longPress.numberOfTouchesRequired = 1
        longPress.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(longPress)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let sceneView = sender.view as? ARSCNView {
            let touchLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = hitTest.first, basketAdded == false {
                addBasketballCoart(with: hitResult)
            }
        }
    }
  
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if basketAdded {
            switch sender.state {
            case .began:
//                timer.perform(closure: { [unowned self] () -> NextStep in
//                    self.power += 1
//                    self.lift += 0.15
//                    return .continue
//                })
                break
            //case .changed:
//                power += 1
//                lift += 0.2
            case .ended:
//                timer.stop()
                shootBall()
            default:
                break
            }
        }
    }
    
}

// MARK: - SCNPhysicsContactDelegate
extension ARHoopsViewController: SCNPhysicsContactDelegate {

    public func collisionDetected(with contact: SCNPhysicsContact) -> (baskeball: SCNNode, didCollide: Bool)? {
        let mask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        if CollisionTypes(rawValue: mask) == [CollisionTypes.projectile, CollisionTypes.target] {

            let firstBody: SCNNode
            let secondBody: SCNNode

            if contact.nodeA.physicsBody!.categoryBitMask < contact.nodeB.physicsBody!.categoryBitMask
            {
                firstBody = contact.nodeA // first body here is the projectile/basketball
                secondBody = contact.nodeB // second body here is the target/score
            } else {
                firstBody = contact.nodeB  // first body here is the projectile/basketball
                secondBody = contact.nodeA // second body here is the target/score
            }

            // we check to see if the two bodies that collide are the projectile and monster, and if so calls the method you wrote earlier.
            if (firstBody.physicsBody!.categoryBitMask & CollisionTypes.projectile.rawValue) == CollisionTypes.projectile.rawValue
                && (secondBody.physicsBody!.categoryBitMask & CollisionTypes.target.rawValue) == CollisionTypes.target.rawValue {
                return (firstBody, true)
            } else {
                return nil
            }
        }
        return nil
    }

    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if let collision = collisionDetected(with: contact), let basketBall = collision.baskeball as? BasketBall {

            if basketBall.tag == basketBallNumber {
                didBeginColliding(with: basketBall)
            }
        }
    }

    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        //if let collision = collisionDetected(with: contact), let basketBall = collision.baskeball as? BasketBall  {
            //didEndColliding(with: basketBall)
        //}
    }
}
