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
    @IBOutlet weak var trackingStateLabel: UILabel!

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
    var planes: [String : SCNNode] = [:]
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

    var currentObjectIndex: Int = 0 {
        didSet {
            
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
            // set the scene to the view
            sceneView.scene = SCNScene()

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

            // Prevent the screen from being dimmed after a while as users will likely
            // have long periods of interaction without touching the screen or buttons.
            UIApplication.shared.isIdleTimerDisabled = true

            //let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(setObjectOnAnchor))
            //tapGestureRecogniser.numberOfTapsRequired = 1
            //sceneView.addGestureRecognizer(tapGestureRecogniser)

        }

    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 12.0, *) {

            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()

            configuration.planeDetection = [.horizontal, .vertical]

            // add environment texture
            configuration.environmentTexturing = .automatic

            // add light estimation
            configuration.isLightEstimationEnabled = true
            // the result of light estimation is provided to you via ARFrame as:
            // let intensity = frame.lightEstimate?.ambientIntensity

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

    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."

        case .notAvailable:
            message = "Tracking unavailable."

        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."

        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."

        case .limited(.initializing):
            message = "Initializing AR session."

        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""

        }
        trackingStateLabel.text = message
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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

    func setObject(hitTestResult: ARHitTestResult, object: Object, zOffset : Float) {
        
        // position is a combination of orientation and location
        let transform = hitTestResult.worldTransform
        //var direction = SCNVector3(x: -transform.columns.2.x, y: -transform.columns.2.y, z: -transform.columns.2.z)
        let position = SCNVector3(x: transform.columns.3.x, y: transform.columns.3.y, z: transform.columns.3.z)

        // select a node - As we know we only loaded one object
        let objectName = String(describing: object)
        let objectScene =
            SCNScene.loadScene(from: ARPhysicallyBasedRenderingViewController.bundle,
                               scnassets: "Scene", name: objectName)!
        node = objectScene.rootNode.childNode(withName: objectName, recursively: false)!
        node.name = objectName
        node.position = position

        setRotation(of: object)

        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
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

        // Create the reflective material and apply it to the sphere
        node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        node.geometry?.firstMaterial?.transparencyMode = .singleLayer

        // Setup the material maps for your object
        let materialFilePrefix = materialPrefixes[index];
        node.geometry?.firstMaterial?.diffuse.contents =
            UIImage(named: "\(materialFilePrefix)-albedo.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        node.geometry?.firstMaterial?.roughness.contents =
            UIImage(named: "\(materialFilePrefix)-roughness.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        node.geometry?.firstMaterial?.metalness.contents =
            UIImage(named: "\(materialFilePrefix)-metal.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        node.geometry?.firstMaterial?.normal.contents =
            UIImage(named: "\(materialFilePrefix)-normal.png", in: ARPhysicallyBasedRenderingViewController.bundle, compatibleWith: nil)
        node.geometry?.firstMaterial?.ambientOcclusion.contents =
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

    // intersect with feature points directly
    // this means that we will find an intersect of long ray which is closest to an existing feature point
    // and returns this as the result as ARAnchor
    @objc func setObjectOnAnchor(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        // first we define our ray and it intersects on our device
        // we provide this as a CGPoint, which is represented in a normalised image space coordinate.
        // this means the top left of out image is (x: 0.0, y: 0.0) and bottom right is (x:1.0, y: 1.0)
        // this is adding an ARAnchor based on hit-test, and it is to find an intersection from the center
        // our screen

        // perform hit-test on tap gesture location
        let location = sender.location(in: sceneView)
        //let halfScreenSize = CGPoint(UIScreen.main.bounds.size.half)
        let hitTest = self.sceneView.hitTest(location, types: [.existingPlane, .existingPlaneUsingExtent])
        setObject(with: hitTest)

    }

    func setObject(with hitTests: [ARHitTestResult]) {
        // use the first result
        if let closestResult = hitTests.first {

            // Create an Anchor for it
            //let anchor = ARAnchor(name: "myAnchor", transform: closestResult.worldTransform)
            //session.add(anchor: anchor)
            setObject(hitTestResult: closestResult, object: Object(rawValue: currentObjectIndex)!, zOffset: 20)
            setMaterial(at: currentMaterialIndex)
            setSubdivisions(value: subdivisionsValue)
            setTesselation(value1: tessalationValue1, value2: tessalationValue2)
            setFillMode(lines: currentFillModeIndex)
        }
    }

    func getWorldMap() -> ARWorldMap? {
        // Retrive world map from session object
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
//            guard let worldMap = worldMap else {
//                //showAlert()
//                return
//            }
        }

        return nil
    }

    func loadWorldMap(map: ARWorldMap) {
        // Load world map and run the configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = map
        sceneView.session.run(configuration)
    }

    deinit {
        print("AR Physically Based Rendering deinit")
    }

}

// MARK: - ARSCNViewDelegate
extension ARPhysicallyBasedRenderingViewController: ARSCNViewDelegate {


    /*
    // Override to create and configure nodes for anchors added to the view's session.
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        return node
    }
*/
    // called 60 times per second (60 fps)
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

    }

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane.init(anchor: planeAnchor,
                               in: sceneView,
                               bundle: ARPhysicallyBasedRenderingViewController.bundle)

        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)

    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? Plane
            else { return }

        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        //if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
        //    planeGeometry.update(from: planeAnchor.geometry)
        //}

        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.extentNode.simdPosition = planeAnchor.center
        }
    }

    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {

    }

    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }


    // MARK: - ARSessionObserver
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
            // showOverlay()
        trackingStateLabel.text = "Session was interrupted"
    }

    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        // hideOverlay()
        trackingStateLabel.text = "Session interruption ended"
        resetTracking()
    }

    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        trackingStateLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
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

            // perform hit-test on frame
            let point = CGPoint(x: 0.5, y: 0.5) // Image center
            let frame = sceneView.session.currentFrame!
            let hitTest = frame.hitTest(point, types: [.existingPlane, .existingPlaneUsingExtent])
            setObject(with: hitTest)

        } else if collectionView == materialsCollectionView {
            currentMaterialIndex = indexPath.row
        } else {

        }
    }
}
