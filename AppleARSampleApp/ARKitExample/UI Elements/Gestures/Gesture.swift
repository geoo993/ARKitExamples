/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages gesture interactions with the AR scene.
*/

import Foundation
import ARKit

class Gesture {
    
    // MARK: - Types
    
	enum TouchEventType {
		case touchBegan
		case touchMoved
		case touchEnded
		case touchCancelled
	}
    
    // MARK: - Properties
    
	let sceneView: ARSCNView
    let objectManager: VirtualObjectManager
    
    var refreshTimer: Timer?
	var lastUsedObject: VirtualObject?
    var currentTouches = Set<UITouch>()
    
    // MARK: - Initialization
    
	init(_ touches: Set<UITouch>, _ sceneView: ARSCNView, _ lastUsedObject: VirtualObject?, _ objectManager: VirtualObjectManager) {
		currentTouches = touches
		self.sceneView = sceneView
		self.lastUsedObject = lastUsedObject
		self.objectManager = objectManager
		
		// Refresh the current gesture at 60 Hz - This ensures smooth updates even when no
		// new touch events are incoming (but the camera might have moved).
		self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.016_667, repeats: true, block: { _ in
			self.refreshCurrentGesture()
		})
	}
    
    // MARK: Static Functions
	
    static func startGestureFromTouches(_ touches: Set<UITouch>, _ sceneView: ARSCNView, _ lastUsedObject: VirtualObject?, _ objectManager: VirtualObjectManager) -> Gesture? {
		if touches.count == 1 {
			return SingleFingerGesture(touches, sceneView, lastUsedObject, objectManager)
		} else if touches.count == 2 {
			return TwoFingerGesture(touches, sceneView, lastUsedObject, objectManager)
		} else {
			return nil
		}
	}
    
    // MARK: - Gesture Handling
	
	func refreshCurrentGesture() {
		if let singleFingerGesture = self as? SingleFingerGesture {
			singleFingerGesture.updateGesture()
		} else if let twoFingerGesture = self as? TwoFingerGesture {
			twoFingerGesture.updateGesture()
		}
	}
	
	func updateGestureFromTouches(_ touches: Set<UITouch>, _ type: TouchEventType) -> Gesture? {
		if touches.isEmpty {
			// No touches -> Do nothing.
			return self
		}
		
		// Update the set of current touches.
		if type == .touchBegan || type == .touchMoved {
			currentTouches = touches.union(currentTouches)
		} else if type == .touchEnded || type == .touchCancelled {
			currentTouches.subtract(touches)
		}
		
		if let singleFingerGesture = self as? SingleFingerGesture {
			
			if currentTouches.count == 1 {
				// Update this gesture.
				singleFingerGesture.updateGesture()
				return singleFingerGesture
			} else {
				// Finish this single finger gesture and switch to two finger or no gesture.
				singleFingerGesture.finishGesture()
				singleFingerGesture.refreshTimer?.invalidate()
				singleFingerGesture.refreshTimer = nil
				return Gesture.startGestureFromTouches(currentTouches, sceneView, lastUsedObject, objectManager)
			}
		} else if let twoFingerGesture = self as? TwoFingerGesture {
			
			if currentTouches.count == 2 {
				// Update this gesture.
				twoFingerGesture.updateGesture()
				return twoFingerGesture
			} else {
				// Finish this two finger gesture and switch to no gesture -> The user
				// will have to release all other fingers and touch the screen again
				// to start a new gesture.
				twoFingerGesture.finishGesture()
				twoFingerGesture.refreshTimer?.invalidate()
				twoFingerGesture.refreshTimer = nil
				return nil
			}
		} else {
			return self
		}
	}
    
}
