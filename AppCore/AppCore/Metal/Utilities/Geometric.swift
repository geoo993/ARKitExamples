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
public func faceforward(_ N: SIMD2<Float>, _ I: SIMD2<Float>, _ Nref: SIMD2<Float>) -> SIMD2<Float> {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: SIMD3<Float>, _ I: SIMD3<Float>, _ Nref: SIMD3<Float>) -> SIMD3<Float> {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: SIMD4<Float>, _ I: SIMD4<Float>, _ Nref: SIMD4<Float>) -> SIMD4<Float> {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: SIMD2<Double>, _ I: SIMD2<Double>, _ Nref: SIMD2<Double>) -> SIMD2<Double> {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: SIMD3<Double>, _ I: SIMD3<Double>, _ Nref: SIMD3<Double>) -> SIMD3<Double> {
    return dot(Nref, I) < 0 ? N : -N
}

/// If dot(Nref, I) < 0.0, return N, otherwise, return -N.
public func faceforward(_ N: SIMD4<Double>, _ I: SIMD4<Double>, _ Nref: SIMD4<Double>) -> SIMD4<Double> {
    return dot(Nref, I) < 0 ? N : -N
}
