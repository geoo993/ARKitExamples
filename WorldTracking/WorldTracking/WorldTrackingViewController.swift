//
//  WorldTrackingViewController.swift
//  WorldTracking
//
//  Created by GEORGE QUENTIN on 27/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import ARKit
import AppCore

public class WorldTrackingViewController: UIViewController {

    var shapeType = ShapeType.random
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet var shapesButtons: [UIButton]!
    
    @IBAction func selectShapeTapped(_ sender: UIButton) {
        toggleDropDownMenu()
    }
    
    @IBAction func shapeTapped(_ sender: UIButton) { 
        selectShape(type: sender.tag)
    }
    
    @IBAction func add(_ sender: UIButton) {
        let x = CGFloat.random(min: -0.3, max: 0.3)
        let y = CGFloat.random(min: -0.3, max: 0.3)
        let z = CGFloat.random(min: -1.5, max: -0.2)
        addNode(at: SCNVector3(x, y, z))
    }
    
    @IBAction func reset(_ sender: UIButton) {
        restartSession()
    }
    
    let configuration = ARWorldTrackingConfiguration()
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(configuration)
        
        view.backgroundColor = UIColor.purple
        
        selectShape(type: 0)
    }
    
    func toggleDropDownMenu () {
        shapesButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: { 
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func selectShape(type : Int) {
        if type >= shapesButtons.count { return }
        shapeType = (type == 9) ? .random : (ShapeType(rawValue: type) ?? .random)
        shapesButtons.forEach { (button) in
            button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            button.titleLabel?.font = UIFont.systemFont(ofSize: (button.titleLabel?.font.pointSize) ?? 17)
        }
        let selectedButton = shapesButtons[type]
        selectedButton.backgroundColor = UIColor.brown.withAlphaComponent(0.8)
        selectedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: (selectedButton.titleLabel?.font.pointSize) ?? 17)
    }
    
    func addNode(at position: SCNVector3) {
        let shape = ShapeGenerator.randomGeometry()
        
        let node = SCNNode()
        node.geometry = shape
        
        /*
          firstMatrerial is the appearance of a surface.
          The reflection of light can be roughly categorized into two types of reflection: 
            - specular reflection is defined as light reflected from a smooth surface at a definite angle. specular is the light that is reflected off the surface at a definite angle
            - diffuse reflection, is produced by rough surfaces that tend to reflect light in all directions.
              diffuse is the color that is spread accross the surface of a geametry
 
        */
        node.geometry?.firstMaterial?.specular.contents = UIColor.random
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.random
        node.position = position
        node.eulerAngles = SCNVector3(CGFloat(0).toRadians, CGFloat(0).toRadians, CGFloat(0).toRadians)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func restartSession () {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

}

extension WorldTrackingViewController: ARSCNViewDelegate {
    
}
