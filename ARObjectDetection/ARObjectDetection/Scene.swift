//
//  Scene.swift
//  ARObjectDetection
//
//  Created by GEORGE QUENTIN on 03/03/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import SpriteKit
import ARKit
import Vision

class ARBridge {

    static let shared = ARBridge()

    var anchorsToIdentifiers = [ARAnchor : String]()

}

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }


        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {

            DispatchQueue.global(qos: .background).async {
                do {
                    let inception = try Inceptionv3(configuration: .init())
                    let model = try VNCoreMLModel(for: inception.model)
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        
                        // Jump onto the main thread
                       // DispatchQueue.main.async {
                            // Access the first result in the array after casting the array as a VNClassificationObservation array
                            guard let results = request.results as? [VNClassificationObservation], let result = results.first else {
                                print ("No results?")
                                return
                            }

                            // Create a transform with a translation of 0.2 meters in front of the camera
                            var translation = matrix_identity_float4x4
                            translation.columns.3.z = -0.4 // Originally this was -0.2
                            let transform = simd_mul(currentFrame.camera.transform, translation)

                            // Add a new anchor to the session
                            let anchor = ARAnchor(transform: transform)
                            // Set the identifier
                            ARBridge.shared.anchorsToIdentifiers[anchor] = result.identifier

                            sceneView.session.add(anchor: anchor)

                        //}
                    })

                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])

                } catch {
                    print(error)
                }
            }


        }
    }
}
