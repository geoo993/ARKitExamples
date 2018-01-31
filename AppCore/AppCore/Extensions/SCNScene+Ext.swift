//
//  SCNScene+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 31/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import SceneKit

extension SCNScene {
    
    public static func loadScene(from bundle: Bundle, scnassets: String, name: String) -> SCNScene? {
        
        guard let directoryPath = bundle.path(forResource: scnassets, ofType: "scnassets") 
            else { 
                return nil 
        }
        //let directoryUrl = URL(fileURLWithPath:directoryPath)
        
        let path = directoryPath+"/"+name+".scn"
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
}
