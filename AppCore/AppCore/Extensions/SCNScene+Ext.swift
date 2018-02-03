//
//  SCNScene+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 31/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import SceneKit

// MARK: - Scene extensions
public extension SCNScene {
    
    public func enableEnvironmentMapWithIntensity(_ intensity: CGFloat, queue: DispatchQueue) {
        queue.async {
            if self.lightingEnvironment.contents == nil {
                if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
                    self.lightingEnvironment.contents = environmentMap
                }
            }
            self.lightingEnvironment.intensity = intensity
        }
    }
    
    public static func loadScene(from bundle: Bundle, scnassets: String, name: String, exten: String = "scn") -> SCNScene? {
        
        guard let directoryPath = bundle.path(forResource: scnassets, ofType: "scnassets") 
            else { 
                return nil 
        }
        //let directoryUrl = URL(fileURLWithPath:directoryPath)
        
        let path = directoryPath+"/"+name+"."+exten
        let sceneURL = URL(fileURLWithPath: path)
        
        // Create a new scene
        return try? SCNScene(url: sceneURL, options: nil)
        
    }
    
    public static func scnPath(from bundle: Bundle, scnassets: String, fileName: String, ofType: String) -> String? {
        guard let directoryPath = bundle.path(forResource: scnassets, ofType: "scnassets") 
            else { 
                return nil 
        }
        return directoryPath+"/"+fileName+"."+ofType
    }
    
    public static func scnDirectory(from bundle: Bundle, scnassets: String) -> String? {
        return bundle.path(forResource: scnassets, ofType: "scnassets")! 
    }
    
    public static func currentPositionOf(camera: SCNNode) -> SCNVector3 {
        let transform = camera.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33) // in the third column in the matrix
        let location = SCNVector3(transform.m41, transform.m42, transform.m43) // the translation in fourth column in the matrix 
        return orientation + location
    }
}
