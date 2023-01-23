//
//  Trigonometric.swift
//  swift3D
//
//  Created by Adrian Krupa on 15.11.2015.
//  Copyright © 2015 Adrian Krupa. All rights reserved.
//

import Foundation
import simd

// MARK: radians

/// Converts degrees to radians and returns the result.
public func radians(degrees: Float) -> Float {
    return degrees * Float(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: SIMD2<Float>) -> SIMD2<Float> {
    return degrees * SIMD2<Float>(repeating: 0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: SIMD3<Float>) -> SIMD3<Float> {
    return degrees * SIMD3<Float>(repeating: 0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: SIMD4<Float>) -> SIMD4<Float> {
    return degrees * SIMD4<Float>(repeating: 0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: Double) -> Double {
    return degrees * Double(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: SIMD2<Double>) -> SIMD2<Double> {
    return degrees * SIMD2<Double>(repeating: 0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: SIMD3<Double>) -> SIMD3<Double> {
    return degrees * SIMD3<Double>(repeating: 0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: SIMD4<Double>) -> SIMD4<Double> {
    return degrees * SIMD4<Double>(repeating: 0.01745329251994329576923690768489)
}

// MARK: degrees
/// Converts radians to degrees and returns the result.
public func degrees(radians: Float) -> Float {
    return radians * Float(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: SIMD2<Float>) -> SIMD2<Float> {
    return radians * SIMD2<Float>(repeating: 57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: SIMD3<Float>) -> SIMD3<Float> {
    return radians * SIMD3<Float>(repeating: 57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: SIMD4<Float>) -> SIMD4<Float> {
    return radians * SIMD4<Float>(repeating: 57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: Double) -> Double {
    return radians * Double(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.

public func degrees(radians: SIMD2<Double>) -> SIMD2<Double> {
    return radians * SIMD2<Double>(repeating: 57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.

public func degrees(radians: SIMD3<Double>) -> SIMD3<Double> {
    return radians * SIMD3<Double>(repeating: 57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.

public func degrees(radians: SIMD4<Double>) -> SIMD4<Double> {
    return radians * SIMD4<Double>(repeating: 57.295779513082320876798154814105)
}

// MARK: sin

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(sin(v.x), sin(v.y))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(sin(v.x), sin(v.y), sin(v.z))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(sin(v.x), sin(v.y), sin(v.z), sin(v.w))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(sin(v.x), sin(v.y))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(sin(v.x), sin(v.y), sin(v.z))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(sin(v.x), sin(v.y), sin(v.z), sin(v.w))
}

// MARK: cos

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(cos(v.x), cos(v.y))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(cos(v.x), cos(v.y), cos(v.z))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(cos(v.x), cos(v.y), cos(v.z), cos(v.w))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(cos(v.x), cos(v.y))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(cos(v.x), cos(v.y), cos(v.z))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(cos(v.x), cos(v.y), cos(v.z), cos(v.w))
}

// TODO: tan
// TODO: asin
// TODO: acos
// TODO: atan
// TODO: sinh
// TODO: cosh
// TODO: tanh
// TODO: asinh
// TODO: acosh
// TODO: atanh

