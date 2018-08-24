//
//  ARDancingViewController.swift
//  ARDancing
//
//  Created by GEORGE QUENTIN on 01/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

// https://www.mixamo.com/#/

import UIKit
import SceneKit
import ARKit
import AppCore
import AVFoundation

public class ARDancingViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARDancingDemo")!
    }
    var audioPlayer : AVAudioPlayer?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var planeDetectedLabel: UILabel!

    @objc func rightBarButtonDidClick() {
        audioPlayer?.stop()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        
        if prepareAudioPlayer() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        planeDetectedLabel.isHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func showHelperAlertIfNeeded() {
        let key = "ARDancingViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Detect horizontal plane and add dancing character.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    func prepareAudioPlayer() -> Bool {
        
        if (audioPlayer == nil){
            audioPlayer = AVAudioPlayer()
        }
        
        do {
            
            guard let path = ARDancingViewController.bundle.path(forResource: "samba", ofType: "m4a") else {
                print("Error: No Audio")
                return false
            }
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path ))
            audioPlayer?.prepareToPlay()
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession
                    .setCategory(AVAudioSession.Category.playback,
                                 mode: AVAudioSession.Mode.default,
                                 options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                return true
            }catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        catch let error {
            print(error.localizedDescription)
            return false
        }
        
    }
    
    func addCharacter(with hitTestResult: ARHitTestResult) {
        
        if let scene = SCNScene.loadScene(from:ARDancingViewController.bundle, 
                                          scnassets: "art",
                                          name: "ty",
                                          exten: "dae"),
            let node = scene.rootNode.childNode(withName: "ty", recursively: false) {

            let scale: CGFloat = 0.005
            let transform = hitTestResult.worldTransform 
            let thirdColumn = transform.columns.3
            let anchorPosition = SCNVector3(x: thirdColumn.x, y: thirdColumn.y, z: thirdColumn.z)
            node.position = anchorPosition
            node.scale = SCNVector3.uniform(to: scale)
            sceneView.scene.rootNode.addChildNode(node)
            
            if let player = audioPlayer {
                player.play()
                player.numberOfLoops = -1
            }
        }
    }
    
    func resetScene () {
        if let player = audioPlayer {
            player.stop()
        }
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }

    deinit {
        print("AR Dancing deinit")
    }
}

// MARK: - ARSCNViewDelegate
extension ARDancingViewController: ARSCNViewDelegate {
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // a plane Anchor encodes the orientation, position and size of a horizontal surface
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async { [unowned self] () in
            self.planeDetectedLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] () in
                self.planeDetectedLabel.isHidden = true
            }
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

// MARK: - Gesture recognizer
extension ARDancingViewController {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = hitTest.first {
                resetScene()
                addCharacter(with: hitResult)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
