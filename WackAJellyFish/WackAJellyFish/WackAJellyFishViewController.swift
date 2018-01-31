//
//  WackAJellyFishViewController.swift
//  WackAJellyFish
//
//  Created by GEORGE QUENTIN on 27/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import ARKit
import AppCore
import Each

public class WackAJellyFishViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.WackAJellyFishDemo")!
    }
    
    var timer = Each(1).seconds // is going to keep counting up by 1 seconds
    var countDown = 10
    var jellyFishs = [SCNNode]()
    
    @IBOutlet  weak var sceneView: ARSCNView!
    @IBOutlet  weak var timerLabel: UILabel!
    @IBOutlet  weak var play: UIButton!
    
    @IBAction func playAction(_ sender: UIButton) {
        setTimer()
        addJellyFish() 
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        reset()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        
        reset()
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        timer.stop()
        
    }

 
    func addJellyFish () {

        // Create a new scene
        if  let scene = SCNScene.loadScene(from: WackAJellyFishViewController.bundle, scnassets: "JellyFish", name: "Jellyfish"), 
            let node = scene.rootNode.childNode(withName: "Jellyfish", recursively: false) {
        
            //let node = SCNNode(geometry: SCNBox(width: 0.4, height: 0.4, length: 0.4, chamferRadius: 0))
            //node.geometry?.firstMaterial?.diffuse.contents = UIColor.random
            
            let x = CGFloat.random(min: -1, max: 1)
            let y = CGFloat.random(min: -0.5, max: 0.5)
            let z = CGFloat.random(min: -1, max: 1)
            node.position = SCNVector3(x,y,z)
            node.name = "Jellyfish"
            sceneView.scene.rootNode.addChildNode(node)
            
            play.isEnabled = false
            countDown = 10
            
            jellyFishs.append(node)
        }
    }
    
    func animate(node: SCNNode) {
        if node.animationKeys.isEmpty {
            SCNTransaction.begin()
            let x = CGFloat.random(min: -0.1, max: 0.1)
            let y = CGFloat.random(min: -0.1, max: 0.1)
            let z = CGFloat.random(min: -0.1, max: 0.1)
            let spin = CABasicAnimation(keyPath: "position")
            spin.setValue("shake", forKey: "shakeAnimation")
            spin.delegate = self//Set delegate
            spin.fromValue = node.presentation.position
            spin.toValue = node.presentation.position + SCNVector3(x, y, z)
            spin.duration = 0.06
            spin.repeatCount = 5
            spin.autoreverses = true
            node.addAnimation(spin, forKey: "position")
            
            SCNTransaction.completionBlock = { [unowned self] () in
                node.removeFromParentNode()
                self.jellyFishs.forEach({ $0.removeFromParentNode() })
                self.jellyFishs.removeAll()
                self.addJellyFish()
            }
            SCNTransaction.commit()
        }
    }
    
    func setTimer() {
        timer.perform { [unowned self] () -> NextStep in
            self.countDown -= 1
            self.timerLabel.text = "\(self.countDown)"
            
            if self.countDown <= 0 {
                self.timerLabel.text = "Out of Time, Game Over!"
                return .stop
            } else {
                return .continue
            }
        }
    }
    
    func restoreTimer () {
        countDown = 10
        timerLabel.text = "\(countDown)"
    }
    
    func reset () {
        timer.stop()
        countDown = 10
        timerLabel.text = "Let's Play"
        play.isEnabled = true
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        jellyFishs.forEach({ $0.removeFromParentNode() })
        jellyFishs.removeAll()
    }
    
    deinit {
        print("WackAJellyFish deinit")
    }
}

// MARK: - CAAnimationDelegate
extension WackAJellyFishViewController: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Unwrap the optional value for the key "animationID" then
        // if it's equal to the same value as the relevant animation,
        // execute the relevant code
        let animationID: AnyObject = anim.value(forKey: "shakeAnimation") as AnyObject
        if animationID as! NSString == "shake" {
            // execute code
            //print("animation completed")
        }
        
    }
}

// MARK: - ARSCNViewDelegate
extension WackAJellyFishViewController : ARSCNViewDelegate {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    // render scene 60 frames per seconds
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
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
extension WackAJellyFishViewController {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation)
            
            if let hitResult = results.first, countDown > 0 {
                let node = hitResult.node
                animate(node: node)
            }
        }
    }
}


