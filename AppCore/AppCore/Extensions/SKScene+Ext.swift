//
//  SKScene+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 03/03/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import SpriteKit

// MARK: - Scene extensions
public extension SKScene {

    public static func loadSpriteKitScene(from bundle: Bundle, name: String, exten: String = "sks") -> SKScene? {
        guard let path = bundle.path(forResource: name, ofType: exten) else { return nil }
        let sceneURL = URL(fileURLWithPath: path)

        do {
            // from https://stackoverflow.com/questions/28685733/how-do-i-link-a-sks-file-to-a-swift-file-in-spritekit
            let sceneData = try Data.init(contentsOf: sceneURL, options: Data.ReadingOptions.mappedIfSafe)
            let archiver = try NSKeyedUnarchiver(forReadingFrom: sceneData)
            print(sceneURL)
            print(sceneData)
            print(archiver)
            archiver.setClass(SKScene.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? SKScene
            archiver.finishDecoding()

            return scene
        } catch {
            print(error)
        }

        return nil
    }
}

