//
//  ARTelevisionViewController.swift
//  ARTelevision
//
//  Created by GEORGE QUENTIN on 31/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AppCore
import AVFoundation
import SpriteKit

public class ARTelevisionViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARTelevisionDemo")!
    }
    
    let musicVideos = ["Sia - Chandelier", 
                       "Sia - The Greatest", 
                       "Sia - You're Never Fully Dressed Without a Smile", 
                       "Sia - Rainbow",
                       "Sia - Never Give Up",
                       "Sia - Elastic Heart"]
    
    var musicVideoNumber = 0 
    var videoSpriteKitNode : SKVideoNode?
    var televisionScreen : SCNNode?
    var spriteKitScene = SKScene()
    
    @IBOutlet var sceneView: ARSCNView!
    @IBAction func tapped(_ sender: UITapGestureRecognizer ) {
        musicVideoNumber = Int.random(min: 0, max: musicVideos.count - 1)
        
        if let screen = televisionScreen {
            let videoName = musicVideos[musicVideoNumber]
            addVideoSpriteKitNode(with: videoName)
            screen.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.isPlaying = true
        
        
        //1. create spritekit video node and specify which video to play
        
        // A SpriteKit scene to contain the SpriteKit video mode
        spriteKitScene = SKScene(size: CGSize(width: sceneView.frame.width, height: sceneView.frame.height))
        spriteKitScene.scaleMode = .aspectFit
        
        //2. create scenekit plane and add the sprite kit scene as its material
        
        // Create a new scene
        if  let scene = SCNScene.loadScene(from: ARTelevisionViewController.bundle, scnassets: "art", name: "television"), 
            let television = scene.rootNode.childNode(withName: "television", recursively: false), 
            let screen = television.childNode(withName: "LCD_Screen", recursively: true){
            screen.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
            
            guard let camera = sceneView.pointOfView else { return }
            let distance : CGFloat = 6
            let cameraPosition = SCNScene.currentPositionOf(camera: camera)
            var direction = SCNVector3.cameraDirection(cameraNode: camera)
            let zPosition = direction.normalize() * distance.float
            
            //television.orientation = camera.orientation
            television.position = cameraPosition + zPosition
            
            television.name = "television"
            
            television.addChildNode(screen)
            sceneView.scene.rootNode.addChildNode(television)
            
            televisionScreen = screen
        }
        
    }
    
    func getVideoPlayer(with name : String) -> AVPlayer?
    {
        let onlineVideoURL = "https://s3.eu-west-2.amazonaws.com/inspirationalfilmsscenes/TheWords/TheWords1.mp4"
        
        if let urlPath = String.getItemPathFromBundle(bundleID: ARTelevisionViewController.bundle.bundleIdentifier!, itemName: name, type: "mp4") {
            return AVPlayer(url: URL(fileURLWithPath: urlPath) )
        } else if let url = ARTelevisionViewController.bundle.url(forResource: name, withExtension: "mp4") {
            return AVPlayer(url: url)
        } else if let url = URL(string: onlineVideoURL) {
            return AVPlayer(url: url )
        }
        
        return nil
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        videoSpriteKitNode?.pause()
        videoSpriteKitNode = nil
        televisionScreen = nil
    }
   
    private func showHelperAlertIfNeeded() {
        let key = "ARTelevisionViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap on screen to play Sia music videos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    func addVideoSpriteKitNode(with name: String) {
        // Create video player, which will be responsable for the playback of the video material
        guard let videoPlayer = getVideoPlayer(with: name) else { return }
        
        if spriteKitScene.children.isEmpty == false {
            spriteKitScene.enumerateChildNodes(withName: "videoNode") { [unowned self] (node, _) in
                node.removeFromParent()
                self.videoSpriteKitNode?.pause()
                self.videoSpriteKitNode = nil
            }
        }
        
        // create the sprite kit video node, containingthe video player
        videoSpriteKitNode = SKVideoNode(avPlayer: videoPlayer)
        videoSpriteKitNode?.name = "videoNode"
        videoSpriteKitNode?.position = CGPoint(x: spriteKitScene.frame.width / 2.0, y: spriteKitScene.frame.height / 2.0)
        videoSpriteKitNode?.size = spriteKitScene.size
        videoSpriteKitNode?.yScale = -1.0
        videoSpriteKitNode?.play()
        
        if let videoNode = videoSpriteKitNode {
            spriteKitScene.addChild(videoNode)
        }
    }
   
    deinit {
        print("AR Television deinit")
    }
    
}


// MARK: - ARSCNViewDelegate
extension ARTelevisionViewController : ARSCNViewDelegate {    
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

