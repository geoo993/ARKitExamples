//
//  ARHomeViewController.swift
//  ARHome
//
//  Created by GEORGE QUENTIN on 01/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://www.youtube.com/watch?v=d8KOf8WLqrc&list=PL2hmCdxlIIusSvVWI4OWblDj-SsBUFK5m&index=3

import UIKit
import SceneKit
import ARKit
import AppCore

public class ARHomeViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARHomeDemo")!
    }
    
    // Create instance variable for more readable access inside class
    public static var serialQueue: DispatchQueue { 
        return DispatchQueue(label: "com.geo-games.ARHomeDemo.serialSceneKitQueue")
    }
    
    // MARK: - UI Elements
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - ARKit Config Properties
    
    var objectsInScene = [SCNNode]()
    var screenCenter: CGPoint?
    var trackingFallbackTimer: Timer?
    
    let session = ARSession()
    let fallbackConfiguration = AROrientationTrackingConfiguration()
    
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Other Properties
    
    var planes = [ARPlaneAnchor: Plane]()
    var textManager: ARTextManager!
    var focusSquare: FocusSquare?

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIControls()
        setupScene()
        setupGestures()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
        
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        screenCenter = nil
        trackingFallbackTimer?.invalidate()
        trackingFallbackTimer = nil
        textManager?.delegate = nil
        textManager = nil
        focusSquare = nil
    }
   
    // MARK: - Setup
    private func showHelperAlertIfNeeded() {
        let key = "ARHomeViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect horizontal plane and Tap to add virtual home in the scene.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    
    func setupScene() {
        
        // set up scene view
        sceneView.setup()
        sceneView.delegate = self
        sceneView.session = session
        // sceneView.showsStatistics = true
        
        sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: ARHomeViewController.serialQueue)
        
        setupFocusSquare()
        
        DispatchQueue.main.async { [unowned self] () in 
            self.screenCenter = self.sceneView.bounds.center
        }
    }
    
    func addHouse(with hitTestResult: ARHitTestResult) {
        
        if let scene = SCNScene.loadScene(from: ARHomeViewController.bundle, scnassets: "art", name: "home"),
            let node = scene.rootNode.childNode(withName: "home", recursively: false) {
            
            let transform = hitTestResult.worldTransform 
            let thirdColumn = transform.columns.3
            let anchorPosition = SCNVector3(x: thirdColumn.x, y: thirdColumn.y, z: thirdColumn.z)
            node.position = anchorPosition
            objectsInScene.append(node)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    deinit {
        print("AR Home deinit")
    }
}

// MARK: - ARTextManagerDelegate
extension ARHomeViewController : ARTextManagerDelegate {
    
    func setupUIControls() {
        textManager = ARTextManager(viewController: self)
        textManager.delegate = self
        
        // Set appearance of message output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        messageLabel.text = ""
    }
    
    public func textManager(didChangeText changedText: String) {
        messageLabel.text = changedText
    }
    
    public func textManager(shouldHideText hide: Bool) {
        messageLabel.isHidden = hide
    }
    
    public func textManager(shouldHidePanel hide: Bool) {
        messageLabel.isHidden = hide
        messagePanel.isHidden = hide
    }
    
}

// MARK: - Planes
extension ARHomeViewController {
    
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        let plane = Plane(anchor)
        planes[anchor] = plane
        node.addChildNode(plane)
        
        textManager.cancelScheduledMessage(forType: .planeEstimation)
        textManager.showMessage("SURFACE DETECTED")
        
        if objectsInScene.isEmpty {
            textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
        }
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    
    func resetTracking() {
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        // reset timer
        if trackingFallbackTimer != nil {
            trackingFallbackTimer!.invalidate()
            trackingFallbackTimer = nil
        }
        
        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
                                    inSeconds: 7.5,
                                    messageType: .planeEstimation)
    }
}

// MARK: - Focus Square
extension ARHomeViewController {
    
    func setupFocusSquare() {
        ARHomeViewController.serialQueue.async { [unowned self] () in 
            self.focusSquare?.isHidden = true
            self.focusSquare?.removeFromParentNode()
            self.focusSquare = FocusSquare()
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
        }
        
        textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
    
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else { return }
        
        DispatchQueue.main.async { [unowned self] () in
            var objectVisible = false
            for object in self.objectsInScene {
                if self.sceneView.isNode(object, insideFrustumOf: self.sceneView.pointOfView!) {
                    objectVisible = true
                    break
                }
            }
            
            if objectVisible {
                self.focusSquare?.hide()
            } else {
                self.focusSquare?.unhide()
            }
            
            let (worldPos, planeAnchor, _) = SCNNode
                .worldPositionFromScreenPosition(screenCenter,
                                                 in: self.sceneView,                     
                                                 objectPos: self.focusSquare?.simdPosition)
            if let worldPos = worldPos {
                ARHomeViewController.serialQueue.async { [unowned self] () in 
                    self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
                }
                self.textManager.cancelScheduledMessage(forType: .focusSquare)
            }
        }
    }
}

// MARK: - SCNSceneRenderer ARSCNViewDelegate
extension ARHomeViewController : ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
 
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateFocusSquare()
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        if let lightEstimate = self.session.currentFrame?.lightEstimate {
            self.sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, 
                                                                   queue: ARHomeViewController.serialQueue)
        } else {
            self.sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: ARHomeViewController.serialQueue)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            ARHomeViewController.serialQueue.async { [unowned self] () in 
                self.addPlane(node: node, anchor: planeAnchor)
                self.objectsInScene.forEach({ object in 
                    object.moveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
                })
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            ARHomeViewController.serialQueue.async { [unowned self] () in 
                self.updatePlane(anchor: planeAnchor)
                self.objectsInScene.forEach({ object in 
                    object.moveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
                })
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            ARHomeViewController.serialQueue.async { [unowned self] () in 
                self.removePlane(anchor: planeAnchor)
            }
        }
    }
  
}

// MARK: - ARSession ARSCNViewDelegate
extension ARHomeViewController {
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable:
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 5.0)
        case .limited:
            // After 10 seconds of limited quality, fall back to 3DOF mode.
            trackingFallbackTimer = Timer
                .scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { [unowned self] _ in
                self.session.run(self.fallbackConfiguration)
                self.textManager.showMessage("Falling back to 3DOF tracking.")
                self.trackingFallbackTimer?.invalidate()
                self.trackingFallbackTimer = nil
            })
        case .normal:
            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
            if trackingFallbackTimer != nil {
                trackingFallbackTimer!.invalidate()
                trackingFallbackTimer = nil
            }
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
        guard let arError = error as? ARError else { return }
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        textManager.blurBackground()
        textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    
        textManager.unblurBackground()
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        //restartExperience(self)
        textManager.showMessage("RESETTING SESSION")
    }
    
}

// MARK: - Error handling
extension ARHomeViewController {
    
    func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
        // Blur the background.
        textManager.blurBackground()
        
        if allowRestart {
            // Present an alert informing about the error that has occurred.
            let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
                self.textManager.unblurBackground()
                //self.restartExperience(self)
            }
            textManager.showAlert(title: title, message: message, actions: [restartAction])
        } else {
            textManager.showAlert(title: title, message: message, actions: [])
        }
    }
}

// MARK: - Gestures Recogniser
extension ARHomeViewController {
    func setupGestures() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecogniser)
        
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        sceneView.addGestureRecognizer(pinchGestureRecogniser)
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if let sceneView = sender.view as? ARSCNView {
            let touchLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = hitTest.first {
                addHouse(with: hitResult)
            }
        }
    }
    
    @objc func pinched(_ sender: UIPinchGestureRecognizer) {
        if let sceneView = sender.view as? ARSCNView {
            let pinchLocation = sender.location(in: sceneView)
            
            let hitTest = sceneView.hitTest(pinchLocation)
            if let hitResult = hitTest.first {
                let node = hitResult.node
                if objectsInScene.contains(node) {
                    let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
                    node.runAction(pinchAction)
                    sender.scale = 1.0
                }
            }
        }
    }

    
}
