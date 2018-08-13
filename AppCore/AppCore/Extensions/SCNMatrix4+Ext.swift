//
//  SCNMatrix4+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 11/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import SceneKit

public extension SCNMatrix4
{
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
    public var scale: SCNVector3 {
        return SCNVector3(m11, m22, m33)
    }

    // TODO: calculation must be verified, this could be incorrect or incomplete
    public func rotation(xAxis: Float, yAxis: Float, zAxis: Float, angle: Float) -> SCNVector3 {
        /*
        your rotation has the form, Code :
        [ ax*ax*(1-c)+c    ax*ay*(1-c)+az*s  ax*az*(1-c)-ay*s   0]
        |ax*ay*(1-c)-az*s   ay*ay*(1-c)+c    ay*az*(1-c)+ax*s   0|
        |ax*az*(1-c)+ay*s  ay*az*(1-c)-ax*s   az*az*(1-c)+c     0|
        [       0                 0                 0           1]

        where (ax, ay, az) defines a unitized axis of rotation, and c and s are the cosine and sine of the angle of rotation.
         */
        let x: Float = xAxis
        let y: Float = yAxis
        let z: Float = zAxis
        let w: Float = angle
        let row1 = SCNVector3(cos(w) + pow(x, 2) * (1 - cos(w)),
                              x * y * (1 - cos(w)) - z * sin(w),
                              x * z * (1 - cos(w)) + y*sin(w))
        let row2 = SCNVector3(y*x*(1-cos(w)) + z*sin(w),
                              cos(w) + pow(y, 2) * (1 - cos(w)),
                              y*z*(1-cos(w)) - x*sin(w))
        let row3 = SCNVector3(z*x*(1 - cos(w)) - y*sin(w),
                              z*y*(1 - cos(w)) + x*sin(w),
                              cos(w) + pow(z, 2) * ( 1 - cos(w)))

        return SCNVector3( row1.dot(vector: row1), row2.dot(vector: row2), row3.dot(vector: row3))
    }
}
