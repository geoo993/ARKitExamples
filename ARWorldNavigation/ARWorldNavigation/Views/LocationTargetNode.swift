//
//  LocationTargetNode.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 25/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import SceneKit
import ARKit
import CoreLocation
import AppCore

public class LocationTargetNode: SCNNode {

    let title: String

    var anchor: ARAnchor? {
        didSet {
            guard let transform = anchor?.transform else { return }
            self.position = transform.position
        }
    }

    var location: CLLocation!

    init(title: String, location: CLLocation) {
        self.title = title
        super.init()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }

    func addSphere(with radius: CGFloat, and color: UIColor) {
        let sphereNode = createSphereNode(with: radius, color: color)
        addChildNode(sphereNode)
    }

    func addNode(with radius: CGFloat, and color: UIColor, and text: String) {
        let sphereNode = createSphereNode(with: radius, color: color)
//        let newText = SCNText(string: title, extrusionDepth: 0.05)
//        newText.font = UIFont (name: "AvenirNext-Medium", size: 1)
//        newText.firstMaterial?.diffuse.contents = UIColor.red
//        let _textNode = SCNNode(geometry: newText)
//        let annotationNode = SCNNode()
//        annotationNode.addChildNode(_textNode)
//        annotationNode.position = sphereNode.position
        addChildNode(sphereNode)
//        addChildNode(annotationNode)
    }
}
