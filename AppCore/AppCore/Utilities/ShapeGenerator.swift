//
//  ShapeGenerator.swift
//  arkit-demo
//
//  Created by ttillage on 7/9/17.
//  Copyright © 2017 CapTech. All rights reserved.
//

import Foundation
import SceneKit

public struct ShapeGenerator {
    
    public static func randomGeometry() -> SCNGeometry {
        let shapeType = ShapeType.random
        let shape : SCNGeometry
        
        switch shapeType {
        case .box:
            shape = SCNBox(width: 0.08, height: 0.08, length: 0.08, chamferRadius: 0.01)
        case .sphere:
            shape = SCNSphere(radius: 0.1)
        case .pyramid:
            shape = SCNPyramid(width: 0.1, height: 0.1, length: 0.3)
        case .torus:
            shape = SCNTorus(ringRadius: 0.1, pipeRadius: 0.02)
        case .capsule:
            shape = SCNCapsule(capRadius: 0.08, height: 0.25 )
        case .cylinder:
            shape = SCNCylinder(radius: 0.05, height: 0.25)
        case .cone:
            shape = SCNCone(topRadius: 0.001, bottomRadius: 0.15, height: 0.25)
        case .tube:
            shape = SCNTube(innerRadius: 0.025, outerRadius: 0.05, height: 0.25)
        case .path:
            let path = UIBezierPath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 0.0, y: 0.2) )
            path.addLine(to: CGPoint(x: 0.2, y: 0.3) )
            path.addLine(to: CGPoint(x: 0.4, y: 0.2) )
            path.addLine(to: CGPoint(x: 0.4, y: 0.0) )
            shape = SCNShape(path: path, extrusionDepth: 0.2)
        }  
        
        return shape
    }
    
    public static func generateSphereInFrontOf(node: SCNNode, physics: Bool, color: UIColor) -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        
        let material = SCNMaterial()
        material.diffuse.contents = color
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        
        let position = SCNVector3(x: 0, y: 0, z: -0.6)
        sphereNode.position = node.convertPosition(position, to: nil)
        
        if physics {
            let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphere, options: nil))
            physicsBody.mass = 2.0
            physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
            sphereNode.physicsBody = physicsBody
        }
        
        return sphereNode
    }
}
