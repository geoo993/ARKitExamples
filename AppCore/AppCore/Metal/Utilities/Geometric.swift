//
//  Geometric.swift
//  swift3D
//
//  Created by Adrian Krupa on 15.11.2015.
//  Copyright © 2015 Adrian Krupa. All rights reserved.
//

import Foundation
import simd

// MARK: faceforward

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: float2, _ I: float2, _ Nref: float2) -> float2 {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: float3, _ I: float3, _ Nref: float3) -> float3 {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: float4, _ I: float4, _ Nref: float4) -> float4 {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: double2, _ I: double2, _ Nref: double2) -> double2 {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: double3, _ I: double3, _ Nref: double3) -> double3 {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: double4, _ I: double4, _ Nref: double4) -> double4 {
    return dot(Nref, I) < 0 ? N : -N
}
