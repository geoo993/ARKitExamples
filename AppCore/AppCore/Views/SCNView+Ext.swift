//
//  SCNView+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 29/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension SCNView {
    
}

extension ARSCNView {
    
    public func camerafront(by amount: Float ) -> matrix_float4x4? {
        guard let currentFrame = self.session.currentFrame else { return nil }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = amount
        return simd_mul(transform, translationMatrix)
    }
    
}
