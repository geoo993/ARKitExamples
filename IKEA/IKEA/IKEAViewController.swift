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
    let planeColor = UIColor.random.withAlphaComponent(0.8)
    let cellIdentifier = "itemsIdentifier"
    let itemsArray = ["cup", "boxing", "table", "vase", "sofa", 
                      "metal chairs", "wineglass", "chest drawer", 
                      "floor lamp", "table lamp", "smart TV", 
                      "roulette", "bed", "coffee table" ]
    var selectedItem : String?
    var planes: [String : SCNNode] = [:]
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.antialiasingMode = .multisampling4X
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWorldOrigin]
        
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    func createPlane(with planeAnchor : ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.005, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: -0.005, z: planeAnchor.center.z)
        addDiffuseMaterial(to: planeNode)
        
        return planeNode
    }
    
    func update(planeNode: SCNNode, with planeAnchor : ARPlaneAnchor) {
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.005, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        planeNode.geometry = plane
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: -0.005, z: planeAnchor.center.z)
        addDiffuseMaterial(to: planeNode)
    }
    
    func addDiffuseMaterial(to plane: SCNNode) {
        let image = UIImage(named: "Models.scnassets/grid.png", in: IKEAViewController.bundle, compatibleWith: nil)
        plane.geometry?.firstMaterial?.diffuse.contents = image ?? planeColor
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
    
    private func showHelperAlertIfNeeded() {
        let key = "IKEAViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect horizontal plane, select an item and Tap to add the selected item in the scene.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    deinit {
        print("IKEA demo deinit")
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
        
        let key = planeAnchor.identifier.uuidString
        let planeNode = createPlane(with: planeAnchor)
        node.addChildNode(planeNode)
        planes[key] = planeNode
        
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            update(planeNode: existingPlane, with: planeAnchor)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        // this function removes any new plane anchor found, as we already have a planeAnchor in the scene
        // or when more than one anchor is added, it is removed and this function is called
        // we need t deal with the plane anchors that have been removed
      
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = planes[key] {
            existingPlane.removeFromParentNode()
            planes.removeValue(forKey: key)
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
