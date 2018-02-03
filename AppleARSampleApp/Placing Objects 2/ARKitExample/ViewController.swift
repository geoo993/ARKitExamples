/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint?
    var trackingFallbackTimer: Timer?
    
    let session = ARSession()
    let fallbackConfiguration = AROrientationTrackingConfiguration()
    
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Virtual Object Manipulation Properties
    
    var dragOnInfinitePlanesEnabled = false
    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.settingsButton.isEnabled = !self.isLoadingObject
                self.addObjectButton.isEnabled = !self.isLoadingObject
                self.restartExperienceButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var restartExperienceButton: UIButton!
    
    // MARK: - Queues
    
    static let serialQueue = DispatchQueue(label: "com.apple.arkitexample.serialSceneKitQueue")
	// Create instance variable for more readable access inside class
	let serialQueue: DispatchQueue = ViewController.serialQueue
	
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Setting.registerDefaults()
		setupUIControls()
        setupScene()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
		if ARWorldTrackingConfiguration.isSupported {
			// Start the ARSession.
			resetTracking()
		} else {
			// This device does not support 6DOF world tracking.
			let sessionErrorMsg = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. " +
			"Please quit the application."
			displayErrorMessage(title: "Unsupported platform", message: sessionErrorMsg, allowRestart: false)
		}
	}
    
    
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
	}
	
    // MARK: - Setup
    
	func setupScene() {
		virtualObjectManager = VirtualObjectManager()
        virtualObjectManager.delegate = self
		
		// set up scene view
		sceneView.setup()
		sceneView.delegate = self
		sceneView.session = session
		// sceneView.showsStatistics = true
		
		sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: serialQueue)
		
		setupFocusSquare()
		
		DispatchQueue.main.async {
			self.screenCenter = self.sceneView.bounds.mid
		}
	}
    
    func setupUIControls() {
        textManager = TextManager(viewController: self)
        
        // Set appearance of message output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        messageLabel.text = ""
    }
	
    // MARK: - ARSCNViewDelegate
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		updateFocusSquare()
		
		// If light estimation is enabled, update the intensity of the model's lights and the environment map
		if let lightEstimate = self.session.currentFrame?.lightEstimate {
			self.sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: serialQueue)
		} else {
			self.sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: serialQueue)
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor {
			serialQueue.async {
				self.addPlane(node: node, anchor: planeAnchor)
				self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
			}
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor {
			serialQueue.async {
				self.updatePlane(anchor: planeAnchor)
				self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
			}
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor {
			serialQueue.async {
				self.removePlane(anchor: planeAnchor)
			}
		}
	}
    
	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)

        switch camera.trackingState {
        case .notAvailable:
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 5.0)
        case .limited:
            // After 10 seconds of limited quality, fall back to 3DOF mode.
            trackingFallbackTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
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
	
    func session(_ session: ARSession, didFailWithError error: Error) {

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
	
	func sessionWasInterrupted(_ session: ARSession) {
		textManager.blurBackground()
		textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
	}
		
	func sessionInterruptionEnded(_ session: ARSession) {
		textManager.unblurBackground()
		session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
		restartExperience(self)
		textManager.showMessage("RESETTING SESSION")
	}
	
    // MARK: - Gesture Recognizers
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesBegan(touches, with: event, in: self.sceneView)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjectManager.virtualObjects.isEmpty {
			chooseObject(addObjectButton)
			return
		}
		virtualObjectManager.reactToTouchesEnded(touches, with: event)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesCancelled(touches, with: event)
	}
	
    // MARK: - Planes
	
	var planes = [ARPlaneAnchor: Plane]()
	
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
		let plane = Plane(anchor)
		planes[anchor] = plane
		node.addChildNode(plane)
		
		textManager.cancelScheduledMessage(forType: .planeEstimation)
		textManager.showMessage("SURFACE DETECTED")
		if virtualObjectManager.virtualObjects.isEmpty {
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

    // MARK: - Focus Square
    
    var focusSquare: FocusSquare?
	
    func setupFocusSquare() {
		serialQueue.async {
			self.focusSquare?.isHidden = true
			self.focusSquare?.removeFromParentNode()
			self.focusSquare = FocusSquare()
			self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
		}
		
		textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
	
	func updateFocusSquare() {
		guard let screenCenter = screenCenter else { return }
		
		DispatchQueue.main.async {
			var objectVisible = false
			for object in self.virtualObjectManager.virtualObjects {
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
			
            let (worldPos, planeAnchor, _) = self.virtualObjectManager.worldPositionFromScreenPosition(screenCenter,
                                                                                                       in: self.sceneView,
                                                                                                       objectPos: self.focusSquare?.simdPosition)
			if let worldPos = worldPos {
				self.serialQueue.async {
					self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
				}
				self.textManager.cancelScheduledMessage(forType: .focusSquare)
			}
		}
	}
    
	// MARK: - Error handling
	
	func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
		// Blur the background.
		textManager.blurBackground()
		
		if allowRestart {
			// Present an alert informing about the error that has occurred.
			let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
				self.textManager.unblurBackground()
				self.restartExperience(self)
			}
			textManager.showAlert(title: title, message: message, actions: [restartAction])
		} else {
			textManager.showAlert(title: title, message: message, actions: [])
		}
	}
    
}
