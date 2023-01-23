//
// Created by Adrian Krupa on 30.11.2015.
// Copyright (c) 2015 Adrian Krupa. All rights reserved.
//

import Foundation
import SceneKit
import simd

public extension SIMD3<Float> {
    var toVector3: SCNVector3 {
        return SCNVector3(x, y, z)
    }

    var toDegress: SIMD3<Float> {
        return SIMD3<Float>(x.toDegrees, y.toDegrees, z.toDegrees)
    }

    var toRadians: SIMD3<Float> {
        return SIMD3<Float>(x.toRadians, y.toRadians, z.toRadians)
    }

    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }

    func normalized() -> SIMD3<Float> {
        return self / length()
    }

    init(_ v: SIMD4<Float>) {
        self.init(v.x, v.y, v.z)
    }
}

public extension SIMD4<Float> {
    
    init(_ v: SIMD3<Float>, _ vw: Float) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = vw
    }
    
    init(_ v: SIMD3<Float>) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = 0


    }
    
    init(_ q: quat) {
        self.init()
        x = q.x
        y = q.y
        z = q.z
        w = q.w
    }
}

public extension SIMD3<Double> {
    
    init(_ v: SIMD4<Double>) {
        self.init(v.x, v.y, v.z)
    }
}

public extension SIMD4<Double> {
    
    init(_ v: SIMD3<Double>, _ vw: Double) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = vw
    }
    
    init(_ v: SIMD3<Double>) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = 0
    }
    
    init(_ q: dquat) {
        self.init()
        x = q.x
        y = q.y
        z = q.z
        w = q.w
    }
}
