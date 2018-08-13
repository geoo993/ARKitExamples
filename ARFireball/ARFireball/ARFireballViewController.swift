//
//  ViewController.swift
//  ARFireball
//
//  Created by GEORGE QUENTIN on 12/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import ARKit
import AppCore

public class ARFireballViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARFireballDemo")!
    }

    @IBOutlet weak var metalKitView: MTKView!

    var session: ARSession!
    var renderer: Renderer!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        /*
        sceneView.antialiasingMode = .multisampling4X

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

        sceneView.autoenablesDefaultLighting = true
 */


        // Set the view to use the default device
        if let view = self.metalKitView {
            //1) Create a reference to the GPU, which is the Device and setup properties
            view.device = MTLCreateSystemDefaultDevice() //  A device is an abstraction of the GPU and provides us a few methods and properties.
            view.clearColor = MTLClearColorMake(0.01, 0.01, 0.01, 1.0)
            view.backgroundColor = UIColor.clear

            guard let device = view.device else {
                fatalError("Your GPU does not support Metal!")
            }
            print("\(device.name)\n")


            // setup scene
            let currentDevice = UIDevice.current.modelName
            let width = CGFloat.width(ofDevice: currentDevice).width
            let height = CGFloat.height(ofDevice: currentDevice).height
            let screenSize = CGSize(width: width, height: height)
            let camera = Camera(fov: 45, size: screenSize, zNear: 0.1, zFar: 100)

            //let scene = GameObjectScene(mtkView: metalKitView, camera: camera)


            // create renderer
            renderer = Renderer(mtkView: view, session: session, bundle: ARFireballViewController.bundle, renderDestination: view)
            renderer.scene = LightsScene(mtkView: view, camera: camera)
            renderer.scene.sceneSizeWillChange(to: screenSize)

            // Setup MTKView and delegate
            metalKitView.delegate = renderer
        }


    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHelperAlertIfNeeded()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()

            //configuration.planeDetection = .horizontal

            // Run the view's session
            session.run(configuration)
        }
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

    deinit {
        session.delegate = nil
        print("AR Fireball deinit")
    }
}

// MARK: - RenderDestinationProvider
extension MTKView : RenderDestinationProvider {
    public var bundle: Bundle {
        return ARFireballViewController.bundle
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
