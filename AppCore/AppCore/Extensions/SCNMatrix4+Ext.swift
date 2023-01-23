//
//  SCNMatrix4+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 11/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import SceneKit


extension SCNMatrix4 {
    // https://stackoverflow.com/questions/42029347/position-a-scenekit-object-in-front-of-scncameras-current-orientation
    // https://gamedev.stackexchange.com/questions/50963/how-to-extract-euler-angles-from-transformation-matrix
    // https://www.opengl.org/discussion_boards/showthread.php/159215-Is-it-possible-to-extract-rotation-translation-scale-given-a-matrix

    /*
     https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/CoreAnimationBasics/CoreAnimationBasics.html#//apple_ref/doc/uid/TP40004514-CH2-SW18
    x [ m11 m12 m13 m14 ]
    y | m21 m22 m23 m24 |
    z | m31 m32 m33 m34 |
    w [ m41 m42 m43 m44 ]
     */

    /*
     // identity
     x [ 1   0   0   0 ]
     y | 0   1   0   0 |
     z | 0   0   1   0 |
     w [ 0   0   0   1 ]
    */
    public var identity: SCNVector4 {
        return  SCNVector4(1, 1, 1, 1)
    }

    /*
    // translation
    x [ 1   0   0   0 ]
    y | 0   1   0   0 |
    z | 0   0   1   0 |
    w [ x   y   z   1 ]
    */
    public var translation: SCNVector3 {
        // the translation/position in fourth column in the matrix
        return  SCNVector3(m41, m42, m43)
    }

    // all the orientation values are reversed so that is why we add a negative value to reverse it back
    public var orientation: SCNVector3 {
        return  SCNVector3(-m31, -m32, -m33) // in the third column in the matrix
    }

    /*
     // translation
     x [ x   0   0   0 ]
     y | 0   y   0   0 |
     z | 0   0   z   0 |
     w [ 0   0   0   1 ]
     */
    //https://math.stackexchange.com/questions/237369/given-this-transformation-matrix-how-do-i-decompose-it-into-translation-rotati
    /// get scale vector from the matrix
    public var scale: SCNVector3 {
        //return SCNVector3(m11, m22, m33)
        let x = SCNVector3(m11, m21, m31).length()
        let y = SCNVector3(m12, m22, m32).length()
        let z = SCNVector3(m13, m23, m33).length()
        return SCNVector3(x, y, z)
    }

    // https://math.stackexchange.com/questions/237369/given-this-transformation-matrix-how-do-i-decompose-it-into-translation-rotati

    // https://math.stackexchange.com/questions/237369/given-this-transformation-matrix-how-do-i-decompose-it-into-translation-rotati
    /// get the rotation matrix
    public var rotationMatrix: SCNMatrix4 {
        let scale = self.scale
        return SCNMatrix4(m11: m11 / scale.x, m12: m12 / scale.y, m13: m13 / scale.z, m14: 0,
                          m21: m21 / scale.x, m22: m22 / scale.y, m23: m23 / scale.z, m24: 0,
                          m31: m31 / scale.x, m32: m32 / scale.y, m33: m33 / scale.z, m34: 0,
                          m41: 0, m42: 0, m43: 0, m44: 1)
    }

    /*
     https://stackoverflow.com/questions/15022630/how-to-calculate-the-angle-from-rotation-matrix
     https://www.learnopencv.com/rotation-matrix-to-euler-angles/
     https://gamedev.stackexchange.com/questions/50963/how-to-extract-euler-angles-from-transformation-matrix
     [ r11   r12   r13   0  ]
     | r21   r22   r23   0  |
     | r31   r32   r33   0  |
     [  0     0     0    1  ]

     The 3 Euler angles are
     𝜽x = atan2(r32, r33)
     𝜽y = atan2(-r31, sqrt((r32 * r32) +  (r33 * r33)))
     𝜽z = atan2(r21, r11);
     */
    /// rotation from rotation matrix in radians
    public var rotation: SCNVector3 {
        let m = rotationMatrix
        let x = atan2(m.m32, m.m33)
        let y = atan2(-m.m31, sqrt((m.m32 * m.m32) + (m.m33 * m.m33)))
        let z = atan2(m.m21, m.m11)
        return SCNVector3(x, y, z)
    }

    public var toFloat4x4: float4x4 {
        return float4x4(SIMD4<Float>(m11, m12, m13, m14),
                        SIMD4<Float>(m21, m22, m23, m24),
                        SIMD4<Float>(m31, m32, m33, m34),
                        SIMD4<Float>(m41, m42, m43, m44))
    }
}
