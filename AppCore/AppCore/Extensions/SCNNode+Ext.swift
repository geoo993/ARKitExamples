//
//  SCNNode+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 28/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import SceneKit

public extension SCNNode {
    
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
    
    public static func createBox(with name: String, radius: CGFloat, at position : SCNVector3, color: UIColor) -> SCNNode {
        let box = SCNBox(width: radius, height: radius, length: radius, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.position = position
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public static func createBox(with name: String, radius: CGFloat, at transform : simd_float4x4 , color: UIColor) -> SCNNode {
        let box = SCNBox(width: radius, height: radius, length: radius, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.simdTransform = transform
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public static func createSphere(with name: String, radius: CGFloat, at position : SCNVector3, color: UIColor) -> SCNNode {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.position = position
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    public static func createSphere(with name: String, radius: CGFloat, at transform : simd_float4x4 , color: UIColor) -> SCNNode {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.simdTransform = transform
        node.name = name
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
}
