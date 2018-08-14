//
// Created by Adrian Krupa on 30.11.2015.
// Copyright (c) 2015 Adrian Krupa. All rights reserved.
//

import Foundation
import SceneKit
import simd

public extension float3 {
    public var toVector3: SCNVector3 {
        return SCNVector3(x, y, z)
    }

    public var toDegress: float3 {
        return float3(x.toDegrees, y.toDegrees, z.toDegrees)
    }

    public var toRadians: float3 {
        return float3(x.toRadians, y.toRadians, z.toRadians)
    }

    
    public init(_ v: float4) {
        self.init(v.x, v.y, v.z)
    }
}

public extension float4 {
    
    public init(_ v: float3, _ vw: Float) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = vw
    }
    
    public init(_ v: float3) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = 0


    }
    
    public init(_ q: quat) {
        self.init()
        x = q.x
        y = q.y
        z = q.z
        w = q.w
    }
}

public extension double3 {
    
    public init(_ v: double4) {
        self.init(v.x, v.y, v.z)
    }
}

public extension double4 {
    
    public init(_ v: double3, _ vw: Double) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = vw
    }
    
    public init(_ v: double3) {
        self.init()
        x = v.x
        y = v.y
        z = v.z
        w = 0
    }
    
    public init(_ q: dquat) {
        self.init()
        x = q.x
        y = q.y
        z = q.z
        w = q.w
    }
}
