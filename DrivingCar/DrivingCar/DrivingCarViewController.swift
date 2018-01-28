//
//  DrivingCarViewController.swift
//  DrivingCar
//
//  Created by GEORGE QUENTIN on 28/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore
import CoreMotion

public class DrivingCarViewController: UIViewController {

    var vehicle = SCNPhysicsVehicle()
    var motionManager = CMMotionManager()
    var orientation : CGFloat = 0
    var accelerationValues = [UIAccelerationValue(0), UIAccelerationValue(0)] // acceleration due to gravity on x and y
    var touched = 0
  
    @IBOutlet weak var sceneView: ARSCNView!
    @IBAction func addCar( _ sender: UIButton) {
        guard let pointOfView = sceneView.pointOfView else { return }
        // position is a combination of orientation and location
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let translation = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let currentPositionOfCamera = orientation + translation
        
        let scene = SCNScene(named: "art.scnassets/car.scn")
        if let chassis = scene?.rootNode.childNode(withName: "chassis", recursively: false),
            let frontRight = chassis.childNode(withName: "frontRightParent", recursively: false),
            let frontLeft = chassis.childNode(withName: "frontLeftParent", recursively: false),
            let rearRight = chassis.childNode(withName: "rearRightParent", recursively: false),
            let rearLeft = chassis.childNode(withName: "rearLeftParent", recursively: false) {
            chassis.position = currentPositionOfCamera
            
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: chassis, options: [SCNPhysicsShape.Option.keepAsCompound : true]) )
            body.mass = 5
            chassis.physicsBody = body
            addVehiclePhysics(to: chassis, 
                              frontRight: frontRight, 
                              frontLeft: frontLeft, 
                              rearRight: rearRight, 
                              rearLeft: rearLeft)
            sceneView.scene.rootNode.addChildNode(chassis)
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        setupAccelerometer()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createConcrete(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        let anchorSize = CGSize(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let anchorPosition = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        let geometry = SCNPlane(width: anchorSize.width, height: anchorSize.height)
        let planeNode = SCNNode(geometry: geometry)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.position = anchorPosition
        planeNode.transform = SCNMatrix4Rotate(planeNode.transform, -Float(90).toRadians , 1, 0, 0)
        
        let body = SCNPhysicsBody(type: .static, shape: nil)
        planeNode.physicsBody = body
        
        return planeNode
    }
    
    func addVehiclePhysics(to car: SCNNode, 
                           frontRight: SCNNode,
                           frontLeft: SCNNode, 
                           rearRight: SCNNode, 
                           rearLeft: SCNNode) {
        guard let carPhysicsBody = car.physicsBody else { return }
        let physicsVehicleWheels = [SCNPhysicsVehicleWheel(node: rearRight),
                                    SCNPhysicsVehicleWheel(node: rearLeft),
                                    SCNPhysicsVehicleWheel(node: frontRight),
                                    SCNPhysicsVehicleWheel(node: frontLeft)]
        
        vehicle = SCNPhysicsVehicle(chassisBody: carPhysicsBody, wheels: physicsVehicleWheels)
        sceneView.scene.physicsWorld.addBehavior(vehicle)
    }
    
    func setupAccelerometer() {
        
        // access accelerometer data from the device
        // if device has accelorameter
        if motionManager.isAccelerometerAvailable {
            
            motionManager.accelerometerUpdateInterval = 1 / 60 // the makes the following function to be triggered 60 times a second
            motionManager.startAccelerometerUpdates(to: OperationQueue.main, 
                                                    withHandler: { [unowned self] (accelerometerData, error) in
                if let error = error {
                    print("Error:", error.localizedDescription)
                    return
                }
                
                if let acceleration = accelerometerData?.acceleration {
                    self.accelerometerDidChange(acceleration: acceleration)
                }
            })
        } else {
            print("Accelerometer not available")
        }
        
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration ) {
        accelerationValues[0] = filtered(previousAcceleration: accelerationValues[0], updatedAcceleration: acceleration.x)
        accelerationValues[1] = filtered(previousAcceleration: accelerationValues[1], updatedAcceleration: acceleration.y)
        let acceleartionDueToGravity = accelerationValues[1]
        orientation = (accelerationValues[0] > 0) ? -CGFloat(acceleartionDueToGravity) : CGFloat(acceleartionDueToGravity)
    }
    
    // filter out any applied acceleration, and only want acceleration due to gravity
    // filteres out any acceleration that is not gravitational 
    func filtered(previousAcceleration: Double, updatedAcceleration: Double) -> Double {
        let kfilteringFactor = 0.5
        return updatedAcceleration * kfilteringFactor + previousAcceleration * (1-kfilteringFactor)
    }
    
}

// MARK: - ARSCNViewDelegate
extension DrivingCarViewController: ARSCNViewDelegate {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createConcrete(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        let planeNode = createConcrete(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // this function removes any new plane anchor found, as we already have a planeAnchor in the scene
        // or when more than one anchor is added, it is removed and this function is called
        // we need t deal with the plane anchors that have been removed
        guard anchor is ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
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
    
    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        var engineForce : CGFloat = 0
        var brakingForce : CGFloat = 0
        vehicle.setSteeringAngle(-orientation, forWheelAt: 2)
        vehicle.setSteeringAngle(-orientation, forWheelAt: 3)
        
        if touched == 1 {
            engineForce = 40
        } else if touched == 2 {
            engineForce = -40
        } else if touched == 3 {
            brakingForce = 100
        } else {
            engineForce = 0
        }
        
        vehicle.applyEngineForce(engineForce, forWheelAt: 0)
        vehicle.applyEngineForce(engineForce, forWheelAt: 1)
        vehicle.applyBrakingForce(brakingForce, forWheelAt: 0)
        vehicle.applyBrakingForce(brakingForce, forWheelAt: 1)
    }
    
}

// MARK: - Gesture recognisers
extension DrivingCarViewController {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else { return }
        touched += touches.count
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = 0
    }

}
