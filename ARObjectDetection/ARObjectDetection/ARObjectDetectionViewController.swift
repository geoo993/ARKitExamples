//
//  ViewController.swift
//  ARObjectDetection
//
//  Created by GEORGE QUENTIN on 03/03/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import AppCore

public class ARObjectDetectionViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARObjectDetectionDemo")!
    }

    @IBOutlet var sceneView: ARSKView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true


//        //if let scene = SKScene(fileNamed: "Scene") {
//        if let scene = SKScene.loadSpriteKitScene(from: ARObjectDetectionViewController.bundle, name: "Scene") {
//            sceneView.presentScene(scene)
//        }

        let scene = Scene(size: self.view.frame.size)
        sceneView.presentScene(scene)

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }

    private func showHelperAlertIfNeeded() {
        let key = "ARObjectDetectionViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Identify objects in the scene, and tap on screen to reveal their description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    deinit {
        print("AR Object Detection deinit")
    }
}

// MARK: - ARSKViewDelegate
extension ARObjectDetectionViewController: ARSKViewDelegate {

    public func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        //DispatchQueue.main.async {}
        guard let identifier = ARBridge.shared.anchorsToIdentifiers[anchor] else {
            return nil
        }

        //let labelNode = SKLabelNode(text: "👾")
        let labelNode = SKLabelNode(text: identifier)

        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        labelNode.fontName = UIFont.boldSystemFont(ofSize: 10).fontName
        labelNode.fontColor = UIColor.random
        return labelNode;
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
