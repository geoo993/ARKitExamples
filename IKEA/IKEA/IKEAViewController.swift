//
//  IKEAViewController.swift
//  IKEA
//
//  Created by GEORGE QUENTIN on 28/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import ARKit
import AppCore

public class IKEAViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.IKEADemo")!
    }
    
    let cellIdentifier = "itemsIdentifier"
    let itemsArray = ["cup", "boxing", "table", "vase", "sofa", 
                      "metal chairs", "wineglass", "chest drawer", 
                      "floor lamp", "table lamp", "smart TV", 
                      "roulette", "bed", "coffee table" ]
    var selectedItem : String?
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.antialiasingMode = .multisampling4X
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        registerGestures()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createPlane(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        let anchorSize = CGSize(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let anchorPosition = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        let image = UIImage(named: "Models.scnassets/grid.png", in: IKEAViewController.bundle, compatibleWith: nil)
        let planeNode = SCNNode(geometry: SCNPlane(width: anchorSize.width, height: anchorSize.height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = image
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.position = anchorPosition
        planeNode.transform = SCNMatrix4Rotate(planeNode.transform, -Float(90).toRadians , 1, 0, 0)
        
        return planeNode
    }
  
    func addItem(with hitTestResult: ARHitTestResult) {
        
        guard let item = selectedItem else { return }
        
        if let scene = SCNScene.loadScene(from: IKEAViewController.bundle, scnassets: "Models", name: item),
            let node = scene.rootNode.childNode(withName: item, recursively: false) {
           
            let transform = hitTestResult.worldTransform 
            let thirdColumn = transform.columns.3
            let anchorPosition = SCNVector3(x: thirdColumn.x, y: thirdColumn.y, z: thirdColumn.z)
            node.position = anchorPosition
            sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    deinit {
        print("IKEA deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension IKEAViewController: ARSCNViewDelegate {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // this function removes any new plane anchor found, as we already have a planeAnchor in the scene
        // or when more than one anchor is added, it is removed and this function is called
        // we need t deal with the plane anchors that have been removed
        guard anchor is ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}

// MARK: - Gestures Recogniser
extension IKEAViewController {
   
    func registerGestures() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecogniser)
        
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        sceneView.addGestureRecognizer(pinchGestureRecogniser)
        
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        longPressGestureRecogniser.minimumPressDuration = 0.1
        sceneView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if let sceneView = sender.view as? ARSCNView {
            let touchLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = hitTest.first {
                addItem(with: hitResult)
            }
        }
    }
    
    @objc func pinched(_ sender: UIPinchGestureRecognizer) {
        if let sceneView = sender.view as? ARSCNView {
            let pinchLocation = sender.location(in: sceneView)
            
            let hitTest = sceneView.hitTest(pinchLocation)
            if let hitResult = hitTest.first {
                let node = hitResult.node
                let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
                node.runAction(pinchAction)
                sender.scale = 1.0
            }
        }
    }
    
    @objc func rotate(_ sender: UILongPressGestureRecognizer) {
        
        if let sceneView = sender.view as? ARSCNView {
            let holdLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest(holdLocation)
            
            if let hitResult = hitTest.first {
                let node = hitResult.node
                
                switch sender.state {
                case .began:
                    let rotateAction = SCNAction.rotateForeverBy(x: 0, y: CGFloat(360).toRadians, z: 0, duration: 1)
                    node.runAction(rotateAction)
                    break
                case .ended:
                    node.removeAllActions()
                    break
                default:
                    break
                }
            }
        
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension IKEAViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? IKEACollectionViewCell else { return UICollectionViewCell() }
        
        let item = itemsArray[indexPath.row]
        cell.itemLabel.text = item
        cell.shouldSelect = false
        
        return cell
    }
  
}

// MARK: - UICollectionViewDelegate
extension IKEAViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? IKEACollectionViewCell else { return }
        cell.shouldSelect = true
        
        let item = itemsArray[indexPath.row]
        selectedItem = item
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? IKEACollectionViewCell else { return }
        cell.shouldSelect = false
    }
}
