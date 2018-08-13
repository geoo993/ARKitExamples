//
//  ViewController.swift
//  ARFireball
//
//  Created by GEORGE QUENTIN on 11/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import ARKit

public class ViewController: UIViewController {

    //public static var bundle : Bundle {
    //    return Bundle(identifier: "com.geo-games.ARFireballDemo")!
    //}

    var session: ARSession!
    //var renderer: Rendererr!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        /*
        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        
        // Set the view to use the default device
        if let view = self.view as? MTKView {
            view.device = MTLCreateSystemDefaultDevice()
            view.backgroundColor = UIColor.clear
            view.delegate = self
            
            guard view.device != nil else {
                print("Metal is not supported on this device")
                return
            }
            
            // Configure the renderer to draw to the view
            renderer = Rendererr(session: session, metalDevice: view.device!, bundle: ARFireballViewController.bundle,
                                renderDestination: view)
            
            renderer.drawRectResized(size: view.bounds.size)
        }


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ARFireballViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
 */

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }

    private func showHelperAlertIfNeeded() {
        let key = "ARFireballViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: title, message: "Tap to add the fireball.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            UserDefaults.standard.set(true, forKey: key)
        }
    }

    /*
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let currentFrame = session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            session.add(anchor: anchor)
        }
    }
*/
    deinit {
        session.delegate = nil
        print("AR Fireball deinit")
    }

}
/*
extension MTKView : RenderDestinationProvider {
}

// MARK: - MTKViewDelegate
extension ARFireballViewController: MTKViewDelegate {

    // Called whenever view changes orientation or layout is changed
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    public func draw(in view: MTKView) {
        renderer.update()
    }
}


// MARK: - ARSessionDelegate
extension ARFireballViewController: ARSessionDelegate {

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
*/
