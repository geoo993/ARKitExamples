//
//  ViewController.swift
//  ARVehicle
//
//  Created by GEORGE QUENTIN on 11/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore
import CoreMotion

public class ARVehicleViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARVehicleDemo")!
    }

    var bottomNode : SCNNode!
    var vehicle = SCNPhysicsVehicle()
    let motionManager = CMMotionManager()
    var orientation: CGFloat = 0
    var accelerationValues: [UIAccelerationValue] = [UIAccelerationValue(0), UIAccelerationValue(0)]
    var touched: Int = 0

    @IBOutlet var sceneView: ARSCNView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        sceneView.antialiasingMode = .multisampling4X

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWorldOrigin]

        sceneView.autoenablesDefaultLighting = true

        setupAccelerometer()

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

    @IBAction func addCar() {

        if let scene = SCNScene.loadScene(from: ARVehicleViewController.bundle, scnassets: "arts", name: "vehicleScene"),
            let chassis = scene.rootNode.childNode(withName: "chassis", recursively: false),
            let frontLeft = chassis.childNode(withName: "frontLeftParent", recursively: false),
            let frontRight = chassis.childNode(withName: "frontRightParent", recursively: false),
            let rearLeft = chassis.childNode(withName: "rearLeftParent", recursively: false),
            let rearRight = chassis.childNode(withName: "rearRightParent", recursively: false) {

            /*
            When you set the value of this property, the node’s rotation, orientation, eulerAngles, position, and scale properties automatically change to match the new transform, and vice versa.
 */
            guard let pointOfView = sceneView.pointOfView else { return }
            // position is a combination of orientation and location
            let transform = pointOfView.transform
            let currentPositionOfCamera = transform.orientation + transform.translation

            let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                      shape: SCNPhysicsShape(node: chassis, options: [SCNPhysicsShape.Option.keepAsCompound : true]))
            body.mass = 5
            chassis.position = currentPositionOfCamera
            chassis.physicsBody = body
            self.vehicle = SCNPhysicsVehicle(chassisBody: chassis.physicsBody!,
                                             wheels: [SCNPhysicsVehicleWheel(node: rearLeft),
                                                      SCNPhysicsVehicleWheel(node: rearRight),
                                                      SCNPhysicsVehicleWheel(node: frontLeft),
                                                      SCNPhysicsVehicleWheel(node: frontRight)])
            self.sceneView.scene.physicsWorld.addBehavior(vehicle)
            self.sceneView.scene.rootNode.addChildNode(chassis)
        }
    }

    // MARK: - Concrete
    private func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let image = UIImage(named: "concrete", in: ARVehicleViewController.bundle, compatibleWith: nil)
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(CGFloat(planeAnchor.extent.z))))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = image
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3((90.0).toRadians, 0, 0)

        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        return concreteNode
    }

    // MARK: - Accelerometer
    public func setupAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60 //

            // the following function will be triggered 60 times a second
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in

                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                ///print("accelerometer is detecting acceleration")
                if let acceleration = data?.acceleration {
                    self?.accelerometerDidChange(acceleration: acceleration)
                }
            }
        } else {
            print("Accelerometer not available")
        }
    }

    func accelerometerDidChange(acceleration: CMAcceleration) {
        accelerationValues[1] = filtered(currentAcceleration: accelerationValues[1], updatedAcceleration: acceleration.y)
        accelerationValues[0] = filtered(currentAcceleration: accelerationValues[0], updatedAcceleration: acceleration.x)

        //print("hori:", acceleration.x, "vert:", acceleration.y, "\n")
        self.orientation = accelerationValues[0] > 0 ?  -accelerationValues[1].toCGFloat : accelerationValues[1].toCGFloat

    }
    func filtered(currentAcceleration: Double, updatedAcceleration: Double) -> Double {
        let kfilteringFactor = 0.5
        return updatedAcceleration * kfilteringFactor + currentAcceleration * (1 - kfilteringFactor)
    }


    // MARK: - Show alert
    private func showHelperAlertIfNeeded() {
        let key = "ARVehicleViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect a horizontal plane. Tap to add the vehicle on the plane.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            UserDefaults.standard.set(true, forKey: key)
        }
    }

    deinit {
        print("AR Vehicle deinit")
    }
}

// MARK: - Gestures
extension ARVehicleViewController {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else { return }
        self.touched += touches.count
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touched = 0
    }
}

// MARK: - ARSCNViewDelegate
extension ARVehicleViewController: ARSCNViewDelegate {

    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()

     return node
     }
     */
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        //print("new flat surface detected, new ARPlaneAnchor added")

    }


    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        //print("updating floor's anchor...")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()

        }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
    }

    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }

        // this function removes any new plane anchor found, as we already have a planeAnchor in the scene
        // or when more than one anchor is added, it is removed and this function is called
        // we need t deal with the plane anchors that have been removed
        guard let _ = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }

    }

    // this fucntion is run once per frame
    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        // front wheel at index of vehicle wheels array
        self.vehicle.setSteeringAngle(-orientation, forWheelAt: 2)
        self.vehicle.setSteeringAngle(-orientation, forWheelAt: 3)

        var engineForce: CGFloat = 0
        var brakingForce: CGFloat = 0
        switch self.touched {
        case 1:
            engineForce = 50
        case 2:
            engineForce = -50
        case 3:
            brakingForce = 200
        default: break
        }

        self.vehicle.applyEngineForce(engineForce, forWheelAt: 0)
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 1)
        self.vehicle.applyBrakingForce(brakingForce, forWheelAt: 0)
        self.vehicle.applyBrakingForce(brakingForce, forWheelAt: 1)

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
