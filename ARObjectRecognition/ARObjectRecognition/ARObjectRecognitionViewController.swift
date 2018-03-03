//
//  ARObjectRecognitionViewController.swift
//  ARObjectRecognition
//
//  Created by GEORGE QUENTIN on 26/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://github.com/hanleyweng/CoreML-in-ARKit
// https://theappspace.com/introduction-coreml-machine-learning/


import UIKit
import SceneKit
import ARKit
import Vision
import CoreML
import AppCore

public class ARObjectRecognitionViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARObjectRecognitionDemo")!
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!

    let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
    var latestPrediction : String = "…" // a variable containing the latest CoreML prediction
    var highestPrediction: (identifier: String, confidence: VNConfidence)!

    // COREML
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.geo-games.dispatchqueueml") // A Serial Queue

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupSceneView()

        setupVisionModel()

        addTapGesture()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func setupSceneView() {
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

        // Enable Default Lighting - makes the 3D text a bit poppier.
        sceneView.autoenablesDefaultLighting = true

        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
    }

    func setupVisionModel() {
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { // (Optional) This can be replaced with other models on https://developer.apple.com/machine-learning/
            fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project from https://developer.apple.com/machine-learning/ . Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
        }

        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: model,
                                                    completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]

        // Begin Loop to Update CoreML
        loopCoreMLUpdate()
    }


    private func showHelperAlertIfNeeded() {
        let key = "ARObjectRecognitionViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Find object for Core ML to iedntify and tap on screen to show the text description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    deinit {
        print("AR Object Recognition deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension ARObjectRecognitionViewController: ARSCNViewDelegate {
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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

// MARK: - CoreML Vision Handling
extension ARObjectRecognitionViewController {

    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)

        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()

            // 2. Loop this function.
            self.loopCoreMLUpdate()
        }

    }

    func classificationCompleteHandler(request: VNRequest, error: Error?) {

        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("No results")
            return
        }

        // Get Classifications
        highestPrediction = observations.first.map({ ($0.identifier, $0.confidence) })
        let top2Classifications = observations[0...1] // top 2 results
        .map({ res -> (String, VNConfidence) in  return (res.identifier, res.confidence) })
        let classificationsString = top2Classifications
            .map({ "\($0) \(String(format:"- %.2f", $1))" })
            .joined(separator: "\n")


        DispatchQueue.main.async { [weak self] () in
            // Print Classifications
            print(classificationsString)
            print("--")

            // Display Debug Text on screen
            var debugText:String = ""
            debugText += classificationsString
            self?.debugTextView.text = debugText

            // Store the latest prediction
            var objectName:String = "…"
            objectName = classificationsString.components(separatedBy: "-")[0]
            objectName = objectName.components(separatedBy: ",")[0]
            self?.latestPrediction = objectName
        }
    }

    func updateCoreML() {

        // Run the Core ML Inceptionv3 classifier on global dispatch queue

        // Get Camera Image as RGB
        let pixelbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixelbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixelbuff!)
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.


        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.


        // Run Image Request
        //DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print(error)
            }
        //}
    }
}


extension ARObjectRecognitionViewController {
    // MARK: - Interaction

    func addTapGesture() {
        // Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {

        // HIT TEST : REAL WORLD
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)

        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.

        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

            // Create 3D Text
            let node: SCNNode = createNewBubbleParentNode(latestPrediction)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
    }

    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.

        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y

        let color = UIColor.random

        // BUBBLE-TEXT
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        let font = UIFont(name: FamilyName.chalkboardSEBold, size: 0.15)
        bubble.font = font
        bubble.alignmentMode = kCAAlignmentCenter
        bubble.firstMaterial?.diffuse.contents = color
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        // bubble.flatness // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)

        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)

        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: sphere)

        // BUBBLE PARENT NODE
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.addChildNode(sphereNode)
        bubbleNodeParent.constraints = [billboardConstraint]

        return bubbleNodeParent
    }
}



