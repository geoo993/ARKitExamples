//
//  Plane.swift
//  ARPhysicallyBasedRenderingDemo
//
//  Created by GEORGE QUENTIN on 25/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import ARKit
import AppCore

public class Plane: SCNNode {

    //let meshNode: SCNNode
    let extentNode: SCNNode
    let bundle: Bundle

    /// - Tag: VisualizePlane
    public init(anchor: ARPlaneAnchor, in sceneView: ARSCNView, bundle: Bundle) {
        self.bundle = bundle
        // Create a mesh to visualize the estimated shape of the plane.
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
            else { fatalError("Can't create plane geometry") }
        meshGeometry.update(from: anchor.geometry)
        //self.meshNode = SCNNode(geometry: meshGeometry)

        // Create a node to visualize the plane's bounding rectangle.
        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        self.extentNode = SCNNode(geometry: extentPlane)
        self.extentNode.simdPosition = anchor.center

        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate it to match the orientation of `ARPlaneAnchor`.
        self.extentNode.eulerAngles.x = -.pi / 2

        super.init()
        let color = UIColor.random
        //self.setupMeshVisualStyle(color: color)
        self.setupExtentVisualStyle(color: color)

        // Add the plane extent and plane geometry as child nodes so they appear in the scene.
        //addChildNode(meshNode)
        addChildNode(extentNode)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    private func setupMeshVisualStyle(color: UIColor) {
        // Make the plane visualization semitransparent to clearly show real-world placement.
        meshNode.opacity = 0.4

        // Use color and blend mode to make planes stand out.
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = color
        material.blendMode = .add
    }
 */

    private func setupExtentVisualStyle(color: UIColor) {
        // Make the extent visualization semitransparent to clearly show real-world placement.
        extentNode.opacity = 0.6

        guard let material = extentNode.geometry?.firstMaterial
            else { fatalError("SCNPlane always has one material") }

        material.diffuse.contents = color
        material.blendMode = .add

        // Use a SceneKit shader modifier to render only the borders of the plane.
        guard let path = bundle.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "Scene.scnassets")
            else { fatalError("Can't find wireframe shader") }
        do {
            let shader = try String(contentsOfFile: path, encoding: .utf8)
            material.shaderModifiers = [.surface: shader]
        } catch {
            fatalError("Can't load wireframe shader: \(error)")
        }
    }
}
