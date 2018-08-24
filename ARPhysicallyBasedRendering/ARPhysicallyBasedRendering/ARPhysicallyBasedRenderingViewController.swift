//
//  ViewController.swift
//  ARPhysicallyBasedRendering
//
//  Created by GEORGE QUENTIN on 23/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://github.com/asavihay/PBROrbs-iOS10-SceneKit
// https://freepbr.com/
// https://www.youtube.com/watch?v=pV_1lPjSZrg
// https://developer.apple.com/videos/play/wwdc2017/604
// https://medium.com/@avihay/amazing-physically-based-rendering-using-the-new-ios-10-scenekit-2489e43f7021


import AVFoundation
import UIKit
import SceneKit
import ARKit
import AppCore

public class ARPhysicallyBasedRenderingViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARPhysicallyBasedRenderingDemo")!
    }

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var materialsCollectionView: UICollectionView!
    @IBOutlet weak var objectsCollectionView: UICollectionView!
    @IBOutlet weak var tesselationSlider1: UISlider!
    @IBOutlet weak var tesselationSlider2: UISlider!

    @IBAction func onSlider(_ sender: UISlider) {
        switch sender.tag {
        case 1:
            tessalationValue1 = sender.value
            break
        case 2:
            tessalationValue2 = sender.value
            break
        case 3:
            subdivisionsValue = sender.value
            break
        default:
            break
        }
    }

    @IBAction func onSwitch(_ sender: UISwitch) {
        currentFillModeIndex = sender.isOn
    }

    @IBAction func onSegmentedControl(_ sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
        case 0:
            self.tesselationSlider2.minimumValue = 0
            self.tesselationSlider2.maximumValue = 50
            self.tessalationType = .uniform
        case 1:
            self.tesselationSlider2.minimumValue = 0
            self.tesselationSlider2.maximumValue = 1
            self.tessalationType = .localSpace
        case 2:
            self.tesselationSlider2.minimumValue = 0
            self.tesselationSlider2.maximumValue = 100
            self.tessalationType = .screenSpace
        default:
            break;
        }

        setSubdivisions(value: subdivisionsValue)
        setTesselation(value1: tessalationValue1, value2: tessalationValue2)
    }

    enum TessalationType: Int {
        case uniform
        case localSpace
        case screenSpace
    }

    enum Object: Int {
        case sphere
        case vase
        case mushroom
        case head
        case cube
        case count
    }

    var node: SCNNode!
    var tessalationType: TessalationType!
    var tessalationValue1: Float = 0 {
        didSet {
            setTesselation(value1: tessalationValue1, value2: tessalationValue2)
        }
    }
    var tessalationValue2: Float = 0 {
        didSet {
            setTesselation(value1: tessalationValue1, value2: tessalationValue2)
        }
    }
    var subdivisionsValue: Float = 0 {
        didSet {
            setSubdivisions(value: subdivisionsValue)
        }
    }

    var setCurrentObject: Bool = false
    var currentObjectIndex: Int = 0 {
        didSet {
            setCurrentObject = true
        }
    }

    var currentMaterialIndex: Int = 0 {
        didSet {
            setMaterial(at: currentMaterialIndex)
        }
    }

    var currentFillModeIndex: Bool = false {
        didSet {
            setFillMode(lines: currentFillModeIndex)
        }
    }

    let materialPrefixes : [String] = ["aluminium",
                                       "bamboo-wood-semigloss",
                                       "cavefloor",
                                       "charcoal",
                                       "chipped-paint",
                                       "copper",
                                       "gold",
                                       "granitesmooth",
                                       "harshbricks",
                                       "haystack",
                                       "iron",
                                       "metalgrid",
                                       "oakfloor2",
                                       "octostone",
                                       "oldplywood",
                                       "paint-peeling",
                                       "plastic",
                                       "rustediron-streaks",
                                       "slipperystonework",
                                       "streaked-marble",
                                       "titanium",
                                       "woodframe",
                                       "wornpaintedwoodsiding"];


    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a new scene
        if let sceneView = self.sceneView {
            // get the scene
            let scene = SCNScene.loadScene(from: ARPhysicallyBasedRenderingViewController.bundle,
                                           scnassets: "Scene", name: "scene")!

            // set the scene to the view
            sceneView.scene = scene

            // Set the view's delegate
            sceneView.delegate = self

            // 1
            //sceneView.showsStatistics = true
            // 2
            //sceneView.allowsCameraControl = true
            // 3
            //sceneView.autoenablesDefaultLighting = true
            // 4
            sceneView.automaticallyUpdatesLighting = true
        }

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 12.0, *) {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()

            configuration.environmentTexturing = .automatic

            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            // Fallback on earlier versions
        }

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

    private func showHelperAlertIfNeeded() {
        let key = "ARPhysicallyBasedRenderingViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Select physical based materials, switch between wireframe and fill mode.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            UserDefaults.standard.set(true, forKey: key)
        }
    }

    func setObject(object: Object, zOffset : Float) {
        // position is a combination of orientation and location
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        var direction = SCNVector3(-transform.m31, -transform.m32, -transform.m33) // in the third column in the matrix
        let location = SCNVector3(transform.m41, transform.m42, transform.m43) // the translation in fourth column in the matrix
        let currentPositionOfCamera = direction + location
        let zPosition = direction.normalize() * zOffset

        if node != nil, sceneView.scene.rootNode.childNodes.contains(where: { $0.name == node.name }) {
            node.removeFromParentNode()
        }

        // select a node - As we know we only loaded one object
        let objectName = String(describing: object)
        let objectScene =
            SCNScene.loadScene(from: ARPhysicallyBasedRenderingViewController.bundle,
                               scnassets: "Scene", name: objectName)!
        node = objectScene.rootNode.childNode(withName: objectName, recursively: false)!
        node.name = objectName
        node.orientation = pointOfView.orientation
        node.position = currentPositionOfCamera + zPosition

        setRotation(of: object)

        sceneView.scene.rootNode.addChildNode(node)
    }

    func setRotation(of object: Object) {
        guard node != nil else { return }
        node.removeAllActions()
        switch object {
        case .sphere, .cube:
            node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 1, z: 1, duration: 10)))
            break
        case .vase, .mushroom, .head:
            node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 10)))
            break
        default:
            break
        }
    }

    func setMaterial(at index: Int) {
        guard node != nil else { return }
        let material = node.geometry?.firstMaterial

        // Create the reflective material and apply it to the sphere
        material?.lightingModel = .physicallyBased
        material?.transparencyMode = .singleLayer

        // Setup the material maps for your object
        let materialFilePrefix = materialPrefixes[index];
        material?.diffuse.contents =
            UIImage(named: "\(materialFilePrefix)-albedo.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        material?.roughness.contents =
            UIImage(named: "\(materialFilePrefix)-roughness.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        material?.metalness.contents =
            UIImage(named: "\(materialFilePrefix)-metal.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        material?.normal.contents =
            UIImage(named: "\(materialFilePrefix)-normal.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        material?.ambientOcclusion.contents =
            UIImage(named: "\(materialFilePrefix)-ao.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
    }

    func setTesselation(value1: Float, value2: Float) {
        guard node != nil, let type = tessalationType else { return }
        let tessellator = SCNGeometryTessellator()

        let geometry = node.geometry!
        geometry.tessellator = tessellator

        switch type {
        case .uniform:
            // Uniform tessellation
            geometry.tessellator?.edgeTessellationFactor = CGFloat(value1)//3.0
            geometry.tessellator?.insideTessellationFactor = CGFloat(value2)//3.0
            break
        case .localSpace:
            // Local space tessellation
            geometry.tessellator?.isAdaptive = true
            geometry.tessellator?.maximumEdgeLength = CGFloat(value2) //0.1 in local space
            break
        case .screenSpace:
            // Screen space tessellation
            geometry.tessellator?.isAdaptive = true
            geometry.tessellator?.isScreenSpace = true
            geometry.tessellator?.maximumEdgeLength = CGFloat(value2)//50 // pixels
            break
        }

        // Geometry smoothing
        geometry.tessellator?.smoothingMode = SCNTessellationSmoothingMode.pnTriangles
    }

    func setSubdivisions(value: Float) {
        guard node != nil else { return }

        let geometry = node.geometry!

        //Subdivision Surfaces
        //Adaptive subdivision on the GPU
        // Enable subdivision surfaces
        geometry.subdivisionLevel = Int(value) // 1
        geometry.wantsAdaptiveSubdivision = true
    }

    func setFillMode(lines: Bool) {
        guard node != nil else { return }
        let material = node.geometry?.firstMaterial
        material?.fillMode = lines ? .lines : .fill
    }

    func setBackground(bg: Any?, env: Any?) {
        // https://stackoverflow.com/questions/50769722/how-to-use-environment-map-in-arkit
        // https://medium.com/@ivannesterenko/realistic-reflections-and-environment-textures-in-arkit-2-0-d8d0f1332eed
        // Setup background - This will be the beautiful blurred background
        // that assist the user understand the 3D envirnoment
        //let bg = UIImage(named: "sphericalBlurred.png")
        //self.sceneView.scene.background.contents = bg

        // Setup Image Based Lighting (IBL) map
        //let env = UIImage(named: "spherical.jpg")
        //self.sceneView.scene.lightingEnvironment.contents = env
        //self.sceneView.scene.lightingEnvironment.intensity = 2.0
    }

    deinit {
        print("AR Physically Based Rendering deinit")
    }

}

// MARK: - ARSCNViewDelegate
extension ARPhysicallyBasedRenderingViewController: ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

    // called 60 times per second (60 fps)
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

        if setCurrentObject {
            setObject(object: Object(rawValue: currentObjectIndex)!, zOffset: 20)
            setMaterial(at: currentMaterialIndex)
            setSubdivisions(value: subdivisionsValue)
            setTesselation(value1: tessalationValue1, value2: tessalationValue2)
            setFillMode(lines: currentFillModeIndex)
            //setBackground(bg: sceneView.scene.background, env: sceneView.scene.background)
            setCurrentObject = false
        }
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }

    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        print(anchors)
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ARPhysicallyBasedRenderingViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == objectsCollectionView {
            return Object.count.rawValue
        } else if collectionView == materialsCollectionView {
            return materialPrefixes.count
        } else {
            return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == objectsCollectionView {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "objectCell", for: indexPath) as? ObjectCell
            let object = Object(rawValue: indexPath.row)!
            cell?.label.text = String(describing: object)
            return cell!
        } else if collectionView == materialsCollectionView {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell
            let image =
                UIImage(named: "\(materialPrefixes[indexPath.row])-albedo.png",
                    in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
            cell?.imageView.image = image
            return cell!
        } else {
            return UICollectionViewCell()
        }
    }

    //MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == objectsCollectionView {
            currentObjectIndex = indexPath.row
        } else if collectionView == materialsCollectionView {
            currentMaterialIndex = indexPath.row
        } else {

        }
    }

}
