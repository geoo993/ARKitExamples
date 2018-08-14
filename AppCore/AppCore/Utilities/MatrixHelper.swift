//
//  MatrixHelper.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

// http://slideplayer.com/slide/4884028/
// http://mathforum.org/mathimages/index.php/Transformation_Matrix

import GLKit.GLKMatrix4
import CoreLocation
import SceneKit

public class MatrixHelper {
 
    public static func rotateAroundY(with matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
        return matrix.rotateAroundY(degrees: degrees)
    }

    public static func translationMatrix(translation : vector_float4) -> matrix_float4x4 {
        return matrix_identity_float4x4.translationMatrix(with: translation)
    }
    
    public static func translationMatrix(with matrix: matrix_float4x4, for translation : vector_float4) -> matrix_float4x4 {
        return matrix.translationMatrix(with: translation)
    }
    
    public static func transformMatrix(for matrix: simd_float4x4, from origin: CLLocation, to location: CLLocation) -> simd_float4x4 {
        let distance = Float(location.distance(from: origin))
        let bearing = GLKMathDegreesToRadians(Float(origin.coordinate.direction(to: location.coordinate)))
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = MatrixHelper.translationMatrix(with: matrix_identity_float4x4, for: position)
        let rotationMatrix = MatrixHelper.rotateAroundY(with: matrix_identity_float4x4, for: bearing)
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
    
}
