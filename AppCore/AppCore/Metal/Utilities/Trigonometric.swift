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
public func radians(degrees: float2) -> float2 {
    return degrees * float2(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: float3) -> float3 {
    return degrees * float3(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: float4) -> float4 {
    return degrees * float4(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: Double) -> Double {
    return degrees * Double(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: double2) -> double2 {
    return degrees * double2(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: double3) -> double3 {
    return degrees * double3(0.01745329251994329576923690768489)
}

/// Converts degrees to radians and returns the result.
public func radians(degrees: double4) -> double4 {
    return degrees * double4(0.01745329251994329576923690768489)
}

// MARK: degrees
/// Converts radians to degrees and returns the result.
public func degrees(radians: Float) -> Float {
    return radians * Float(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: float2) -> float2 {
    return radians * float2(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: float3) -> float3 {
    return radians * float3(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: float4) -> float4 {
    return radians * float4(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.
public func degrees(radians: Double) -> Double {
    return radians * Double(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.

public func degrees(radians: double2) -> double2 {
    return radians * double2(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.

public func degrees(radians: double3) -> double3 {
    return radians * double3(57.295779513082320876798154814105)
}

/// Converts radians to degrees and returns the result.

public func degrees(radians: double4) -> double4 {
    return radians * double4(57.295779513082320876798154814105)
}

// MARK: sin

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: float2) -> float2 {
    return float2(sin(v.x), sin(v.y))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: float3) -> float3 {
    return float3(sin(v.x), sin(v.y), sin(v.z))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: float4) -> float4 {
    return float4(sin(v.x), sin(v.y), sin(v.z), sin(v.w))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: double2) -> double2 {
    return double2(sin(v.x), sin(v.y))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: double3) -> double3 {
    return double3(sin(v.x), sin(v.y), sin(v.z))
}

/// The standard trigonometric sine function.
/// The values returned by this function will range from [-1, 1].

public func sin(_ v: double4) -> double4 {
    return double4(sin(v.x), sin(v.y), sin(v.z), sin(v.w))
}

// MARK: cos

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: float2) -> float2 {
    return float2(cos(v.x), cos(v.y))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: float3) -> float3 {
    return float3(cos(v.x), cos(v.y), cos(v.z))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: float4) -> float4 {
    return float4(cos(v.x), cos(v.y), cos(v.z), cos(v.w))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: double2) -> double2 {
    return double2(cos(v.x), cos(v.y))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: double3) -> double3 {
    return double3(cos(v.x), cos(v.y), cos(v.z))
}

/// The standard trigonometric cosine function.
/// The values returned by this function will range from [-1, 1].

public func cos(_ v: double4) -> double4 {
    return double4(cos(v.x), cos(v.y), cos(v.z), cos(v.w))
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

