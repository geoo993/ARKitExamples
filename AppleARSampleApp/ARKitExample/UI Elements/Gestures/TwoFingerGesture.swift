/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages two finger gesture interactions with the AR scene.
*/

import ARKit
import SceneKit

class TwoFingerGesture: Gesture {
    
    // MARK: - Properties
    
    var firstTouch = UITouch()
    var secondTouch = UITouch()
    
    let translationThreshold: CGFloat = 40
    let translationThresholdHarder: CGFloat = 70
    var translationThresholdPassed = false
    var allowTranslation = false
    var dragOffset = CGPoint()
    var initialMidPoint = CGPoint(x: 0, y: 0)
    
    let rotationThreshold: Float = .pi / 15 // (12°)
    let rotationThresholdHarder: Float = .pi / 10 // (18°)
    var rotationThresholdPassed = false
    var allowRotation = false
    var initialFingerAngle: Float = 0
    var initialObjectAngle: Float = 0
    var firstTouchWasOnObject: VirtualObject?
    
    let scaleThreshold: CGFloat = 50
    let scaleThresholdHarder: CGFloat = 90
    var scaleThresholdPassed = false
    var allowScaling = false
    var initialDistanceBetweenFingers: CGFloat = 0
    var baseDistanceBetweenFingers: CGFloat = 0
    var objectBaseScale: Float = 1.0
    
    // MARK: - Initialization
    
    override init(_ touches: Set<UITouch>, _ sceneView: ARSCNView, _ lastUsedObject: VirtualObject?, _ objectManager: VirtualObjectManager) {
        super.init(touches, sceneView, lastUsedObject, objectManager)
        
        firstTouch = currentTouches[currentTouches.index(currentTouches.startIndex, offsetBy: 0)]
        secondTouch = currentTouches[currentTouches.index(currentTouches.startIndex, offsetBy: 1)]
        
        let loc1 = firstTouch.location(in: sceneView)
        let loc2 = secondTouch.location(in: sceneView)
        
        let mp = (loc1 + loc2) / 2
        initialMidPoint = mp
        
        // Check if any of the two fingers or their midpoint is touching the object.
        // Based on that, translation, rotation and scale will be enabled or disabled.
        
        // Compute the two other corners of the rectangle defined by the two fingers
        // and compute the points in between.
        let oc1 = CGPoint(x: loc1.x, y: loc2.y)
        let oc2 = CGPoint(x: loc2.x, y: loc1.y)
        
        //  Compute points in between.
        let dp1 = (oc1 + loc1) / 2
        let dp2 = (oc1 + loc2) / 2
        let dp3 = (oc2 + loc1) / 2
        let dp4 = (oc2 + loc2) / 2
        let dp5 = (mp + loc1) / 2
        let dp6 = (mp + loc2) / 2
        let dp7 = (mp + oc1) / 2
        let dp8 = (mp + oc2) / 2
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        var hitTestResults = [SCNHitTestResult]()
        hitTestResults.append(contentsOf: sceneView.hitTest(loc1, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(loc2, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(oc1, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(oc2, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp1, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp2, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp3, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp4, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp5, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp6, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp7, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(dp8, options: hitTestOptions))
        hitTestResults.append(contentsOf: sceneView.hitTest(mp, options: hitTestOptions))
        for result in hitTestResults {
            let object = VirtualObject.isNodePartOfVirtualObject(result.node)
            if object != nil {
                firstTouchWasOnObject = object
                break
            }
        }
        
        if let virtualObject = firstTouchWasOnObject {
            objectBaseScale = virtualObject.simdScale.x
            
            allowTranslation = true
            allowRotation = true
            // Allow scale if the fingers are on the object or if the object is scaled very small,
            // and if the scale gesture has been enabled in Settings.
            let scaleGestureEnabled = UserDefaults.standard.bool(for: .scaleWithPinchGesture)
            allowScaling = scaleGestureEnabled
            
            let loc2ToLoc1 = loc1 - loc2
            initialDistanceBetweenFingers = loc2ToLoc1.length()
            
            let midPointToLoc1 = loc2ToLoc1 / 2
            initialFingerAngle = atan2(Float(midPointToLoc1.x), Float(midPointToLoc1.y))
            initialObjectAngle = virtualObject.eulerAngles.y
        } else {
            allowTranslation = false
            allowRotation = false
            allowScaling = false
        }
    }
    
    // MARK: - Gesture Handling
    
    func updateGesture() {
        
        guard let virtualObject = firstTouchWasOnObject else {
            return
        }
        
        // Two finger touch enables combined translation, rotation and scale.
        
        // First: Update the touches.
        let newTouch1 = currentTouches[currentTouches.index(currentTouches.startIndex, offsetBy: 0)]
        let newTouch2 = currentTouches[currentTouches.index(currentTouches.startIndex, offsetBy: 1)]
        
        if newTouch1.hashValue == firstTouch.hashValue {
            firstTouch = newTouch1
            secondTouch = newTouch2
        } else {
            firstTouch = newTouch2
            secondTouch = newTouch1
        }
        
        let loc1 = firstTouch.location(in: sceneView)
        let loc2 = secondTouch.location(in: sceneView)
        
        if allowTranslation {
            // 1. Translation using the midpoint between the two fingers.
            updateTranslation(of: virtualObject, midpoint: loc1.midpoint(loc2))
        }
        
        let spanBetweenTouches = loc1 - loc2
        if allowRotation {
            // 2. Rotation based on the relative rotation of the fingers on a unit circle.
            updateRotation(of: virtualObject, span: spanBetweenTouches)
        }
        if allowScaling {
            // 3. Scale based on the distance between the fingers relative to initial distance.
            updateScaling(of: virtualObject, span: spanBetweenTouches)
        }
    }
    
    func updateTranslation(of virtualObject: VirtualObject, midpoint: CGPoint) {
        if !translationThresholdPassed {
            
            let initialLocationToCurrentLocation = midpoint - initialMidPoint
            let distanceFromStartLocation = initialLocationToCurrentLocation.length()
            
            // Check if the translate gesture has crossed the threshold.
            // If the user is already rotating and or scaling we use a bigger threshold.
            
            var threshold = translationThreshold
            if rotationThresholdPassed || scaleThresholdPassed {
                threshold = translationThresholdHarder
            }
            
            if distanceFromStartLocation >= threshold {
                translationThresholdPassed = true
                
                let currentObjectLocation = CGPoint(sceneView.projectPoint(virtualObject.position))
                dragOffset = midpoint - currentObjectLocation
            }
        }
        
        if translationThresholdPassed {
            let offsetPos = midpoint - dragOffset
            objectManager.translate(virtualObject, in: sceneView, basedOn: offsetPos, instantly: false, infinitePlane: true)
            lastUsedObject = virtualObject
        }
    }
    
    func updateRotation(of virtualObject: VirtualObject, span: CGPoint) {
        let midpointToFirstTouch = span / 2
        let currentAngle = atan2(Float(midpointToFirstTouch.x), Float(midpointToFirstTouch.y))
        
        let currentAngleToInitialFingerAngle = initialFingerAngle - currentAngle
        
        if !rotationThresholdPassed {
            var threshold = rotationThreshold
            
            if translationThresholdPassed || scaleThresholdPassed {
                threshold = rotationThresholdHarder
            }
            
            if abs(currentAngleToInitialFingerAngle) > threshold {
                
                rotationThresholdPassed = true
                
                // Change the initial object angle to prevent a sudden jump after crossing the threshold.
                if currentAngleToInitialFingerAngle > 0 {
                    initialObjectAngle += threshold
                } else {
                    initialObjectAngle -= threshold
                }
            }
        }
        
        if rotationThresholdPassed {
            // Note:
            // For looking down on the object (99% of all use cases), we need to subtract the angle.
            // To make rotation also work correctly when looking from below the object one would have to
            // flip the sign of the angle depending on whether the object is above or below the camera...
            virtualObject.eulerAngles.y = initialObjectAngle - currentAngleToInitialFingerAngle
            lastUsedObject = virtualObject
        }
    }
    
    func updateScaling(of virtualObject: VirtualObject, span: CGPoint) {
        let distanceBetweenFingers = span.length()
        
        if !scaleThresholdPassed {
            
            let fingerSpread = abs(distanceBetweenFingers - initialDistanceBetweenFingers)
            
            var threshold = scaleThreshold
            
            if translationThresholdPassed || rotationThresholdPassed {
                threshold = scaleThresholdHarder
            }
            
            if fingerSpread > threshold {
                scaleThresholdPassed = true
                baseDistanceBetweenFingers = distanceBetweenFingers
            }
        }
        
        if scaleThresholdPassed {
            if baseDistanceBetweenFingers != 0 {
                let relativeScale = distanceBetweenFingers / baseDistanceBetweenFingers
                let newScale = objectBaseScale * Float(relativeScale)
                
                // Uncomment the block below to "snap" the 3D model to 100%.
                /*
                 if newScale >= 0.96 && newScale <= 1.04 {
                 newScale = 1.0 // Snap scale to 100% when getting close.
                 }*/
                
                virtualObject.simdScale = float3(newScale)
                lastUsedObject = virtualObject
                
                ViewController.serialQueue.async {
                    if let nodeWhichReactsToScale = virtualObject.reactsToScale() {
                        nodeWhichReactsToScale.reactToScale()
                    }
                }
            }
        }
    }
    
    func finishGesture() {
        // Nothing to do here for two finger gestures.
    }
}

