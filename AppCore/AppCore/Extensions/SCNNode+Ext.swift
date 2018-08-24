//
//  SCNNode+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 28/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import SceneKit
import ARKit

public extension SCNNode {
    
    public func setUniformScale(_ scale: Float) {
        self.simdScale = float3(scale, scale, scale)
    }
    
    public func renderOnTop(_ enable: Bool) {
        self.renderingOrder = enable ? 2 : 0
        if let geom = self.geometry {
            for material in geom.materials {
                material.readsFromDepthBuffer = enable ? false : true
            }
        }
        for child in self.childNodes {
            child.renderOnTop(enable)
        }
    }
    
    public func centerAtPivotPoint() {
        let node = self
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
    public static func createBox(with name: String, radius: CGFloat, position : SCNVector3, color: UIColor) -> SCNNode {
        let box = SCNBox(width: radius, height: radius, length: radius, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.position = position
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public static func createBox(with name: String, radius: CGFloat, transform : simd_float4x4 , color: UIColor) -> SCNNode {
        let box = SCNBox(width: radius, height: radius, length: radius, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.simdTransform = transform
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public static func createSphere(with name: String, radius: CGFloat, position : SCNVector3, color: UIColor) -> SCNNode {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.position = position
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public static func createSphere(with name: String, radius: CGFloat, transform : simd_float4x4 , color: UIColor) -> SCNNode {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.simdTransform = transform
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public func moveOntoPlane(anchor: ARPlaneAnchor, planeAnchorNode: SCNNode) {
       
        // Get the object's position in the plane's coordinate system.
        let objectPos = planeAnchorNode.convertPosition(self.position, from: self.parent)
        
        if objectPos.y == 0 {
            return; // The object is already on the plane - nothing to do here.
        }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        
        if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
            return
        }
        
        // Move the object onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not bother updating if the different is less than a mm.
        let distanceToPlane = abs(objectPos.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
          
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
        
    }
    
    public func transform(from cameraTransform: matrix_float4x4) 
        -> (distance: Float, rotation: Int, scale: Float) {
        let cameraPos = cameraTransform.translation
        let vectorToCamera = cameraPos - self.simdPosition
        
        let distanceToUser = simd_length(vectorToCamera)
        
        var angleDegrees = Int((self.eulerAngles.y * 180) / .pi) % 360
        if angleDegrees < 0 {
            angleDegrees += 360
        }
        
        return (distanceToUser, angleDegrees, self.scale.x)
    }
    
    
    public static func worldPositionFromScreenPosition(_ position: CGPoint,
                                                       in sceneView: ARSCNView,
                                                       objectPos: float3?,
                                                       infinitePlane: Bool = false) 
        -> (position: float3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let dragOnInfinitePlanesEnabled = UserDefaults.standard.bool(for: .dragOnInfinitePlanes)
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: float3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            if let pointOnPlane = objectPos {
                let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
                if pointOnInfinitePlane != nil {
                    return (pointOnInfinitePlane, nil, true)
                }
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    
}
