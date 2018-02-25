//
//  Matrix+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-two-7b045fb1d7a1
// https://sites.math.washington.edu/~king/coursedir/m308a01/Projects/m308a01-pdf/yip.pdf
// http://mathforum.org/mathimages/index.php/Transformation_Matrix
// https://open.gl/transformations

import simd
import GLKit.GLKMatrix4
import SceneKit

extension matrix_float4x4 {
    
    public var position: SCNVector3 {
        
        //    column 0  column 1  column 2  column 3
        //         1        0         0       X       
        //         0        1         0       Y      
        //         0        0         1       Z       
        //         0        0         0       1    
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
    
    public func rotateAroundX(for degrees: Float) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //         1      0         θ        0    
        //         0     cosθ      -sinθ     0    
        //         0     sinθ      cosθ      0    
        //         0      0         0        1    
        
        var matrix : matrix_float4x4 = self
        matrix.columns.1.y = cos(degrees)
        matrix.columns.1.z = sin(degrees)
        
        matrix.columns.2.x = -sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    public func rotateAroundY(for degrees: Float) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //        cosθ      0       sinθ      0    
        //         0        1         0       0    
        //       −sinθ      0       cosθ      0    
        //         0        0         0       1    
        
        var matrix : matrix_float4x4 = self
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    public func rotateAroundZ(for degrees: Float) -> matrix_float4x4 {
        //      column 0   column 1  column 2  column 3
        //        cosθ    -sinθ       θ        0    
        //        sinθ     cosθ       0        0    
        //         0        0         1        0    
        //         0        0         0        1    
        
        var matrix : matrix_float4x4 = self
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.y = sin(degrees)
        
        matrix.columns.1.x = -sin(degrees)
        matrix.columns.1.y = cos(degrees)
        return matrix.inverse
    }
    
    public func translationMatrix(with translation : vector_float4) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //         1        0         0       X          x        x + X*w 
        //         0        1         0       Y      x   y    =   y + Y*w 
        //         0        0         1       Z          z        z + Z*w 
        //         0        0         0       1          w           w    
        var matrix = self
        matrix.columns.3 = translation
        return matrix
    }
    
    public func scale(by size: Float) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //         1        0       0      0    
        //         0        1       0      0    
        //         0        0       1      0    
        //         0        0       0      1    
        
        var matrix : matrix_float4x4 = self
        matrix.columns.0.x = size
        matrix.columns.1.y = size
        matrix.columns.2.z = size
        return matrix
    }
    
}

public extension float4x4 {
    
    init() {
        self = unsafeBitCast(GLKMatrix4Identity, to: float4x4.self)
    }
    
    /// Treats matrix as a (right-hand column-major convention) transform matrix
    /// and factors out the translation component of the transform.
    public var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
   
    public static func makeScale(_ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeScale(x, y, z), to: float4x4.self)
    }
    
    public static func makeRotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeRotation(radians, x, y, z), to: float4x4.self)
    }
    
    public static func makeTranslation(_ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeTranslation(x, y, z), to: float4x4.self)
    }
    
    public static func makePerspective(fovyRadians: Float, _ aspect: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakePerspective(fovyRadians, aspect, nearZ, farZ), to: float4x4.self)
    }

    public static func makeFrustum(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeFrustum(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
    }
    
    public static func makeOrtho(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeOrtho(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
    }
    
    public static func makeLookAt(eyeX: Float, _ eyeY: Float, _ eyeZ: Float, _ centerX: Float, _ centerY: Float, _ centerZ: Float, _ upX: Float, _ upY: Float, _ upZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ), to: float4x4.self)
    }
    
    public func scale(x: Float, y: Float, z: Float) -> float4x4 {
        return self * float4x4.makeScale(x, y, z)
    }
    
    public func rotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return self * float4x4.makeRotate(radians: radians, x, y, z)
    }
    
    public mutating func rotateAroundX(_ x: Float, y: Float, z: Float) {
        var rotationM = float4x4.makeRotate(radians:x, 1, 0, 0)
        rotationM = rotationM * float4x4.makeRotate(radians: y, 0, 1, 0)
        rotationM = rotationM * float4x4.makeRotate(radians: z, 0, 0, 1)
        self = self * rotationM
    }
    
    public func translate(x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return self * float4x4.makeTranslation(x, y, z)
    }
    
    public static var numberOfElements : Int {
        return 16
    }
    
    public static func degrees(toRad angle: Float) -> Float {
        return Float(angle.toRadians)
    }
    
    public mutating func multiplyLeft(_ matrix: float4x4) {
        let glMatrix1 = unsafeBitCast(matrix, to: GLKMatrix4.self)
        let glMatrix2 = unsafeBitCast(self, to: GLKMatrix4.self)
        let result = GLKMatrix4Multiply(glMatrix1, glMatrix2)
        self = unsafeBitCast(result, to: float4x4.self)
    }
    
}
