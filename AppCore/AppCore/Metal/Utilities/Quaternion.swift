//
//  Quaternion.swift
//  swift3D
//
//  Created by Adrian Krupa on 30.11.2015.
//  Copyright © 2015 Adrian Krupa. All rights reserved.
//

import Foundation
import simd

public struct quat: ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    public var x: Float
    public var y: Float
    public var z: Float
    public var w: Float

    public init() {
        x = 0
        y = 0
        z = 0
        w = 1
    }

    public init(w: Float, v: float3) {
        x = v.x
        y = v.y
        z = v.z
        self.w = w
    }
    
    public init(angle: Float, axis: float3) {
        self = angleAxis(angle: angle, axis: axis)
    }

    public init(_ w: Float, _ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    public init(_ q: quat) {
        x = q.x
        y = q.y
        z = q.z
        w = q.w
    }

    /// Initialize to a vector with elements taken from `array`.
    ///
    /// - Precondition: `array` must have exactly four elements.
    public init(_ array: [Float]) {
        x = array[0]
        y = array[1]
        z = array[2]
        w = array[3]
    }

    /// Initialize using `arrayLiteral`.
    ///
    /// - Precondition: the array literal must exactly four elements.
    public init(arrayLiteral elements: Float...) {
        x = elements[0]
        y = elements[1]
        z = elements[2]
        w = elements[3]
    }

    /// Create a quaternion from two normalized axis
    /// @see http://lolengine.net/blog/2013/09/18/beautiful-maths-quaternion-from-vectors
    public init(_ u: float3, _ v: float3) {
        let LocalW = cross(u, v)
        let Dot = dot(u, v)
        let q = quat(1 + Dot, LocalW.x, LocalW.y, LocalW.z)
        self.init(normalize(q))
    }

    public init(_ eulerAngle: float3) {
        let c = cos(eulerAngle * Float(0.5))
        let s = sin(eulerAngle * Float(0.5))

        w = c.x * c.y * c.z + s.x * s.y * s.z
        x = s.x * c.y * c.z - c.x * s.y * s.z
        y = c.x * s.y * c.z + s.x * c.y * s.z
        z = c.x * c.y * s.z - s.x * s.y * c.z
    }

    public init(_ m: float3x3) {
        self.init(quat_cast(m))
    }

    public init(_ m: float4x4) {
        self.init(quat_cast(m))
    }

    public var debugDescription: String {
        get {
            return ""
        }
    }
}

prefix public func +(q: quat) -> quat {
    return q
}

prefix public func -(q: quat) -> quat {
    return quat(-q.w, -q.x, -q.y, -q.z)
}

public func +(q: quat, p: quat) -> quat {
    return quat(q.w + p.w, q.x + p.x, q.y + p.y, q.z + p.z)
}

public func *(p: quat, q: quat) -> quat {
    
    let w = p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z
    let x = p.w * q.x + p.x * q.w + p.y * q.z - p.z * q.y
    let y = p.w * q.y + p.y * q.w + p.z * q.x - p.x * q.z
    let z = p.w * q.z + p.z * q.w + p.x * q.y - p.y * q.x
    return quat(w, x, y, z)
}

public func *(q: quat, v: float3) -> float3 {
    let QuatVector = float3(q.x, q.y, q.z)
    let uv = cross(QuatVector, v)
    let uuv = cross(QuatVector, uv)

    return v + ((uv * q.w) + uuv) * Float(2)
}

public func *(v: float3, q: quat) -> float3 {
    return inverse(q) * v
}

public func *(q: quat, v: float4) -> float4 {
    return float4(q * float3(v), v.w)
}

public func *(v: float4, q: quat) -> float4 {
    return inverse(q) * v
}

public func *(q: quat, p: Float) -> quat {
    return quat( q.w * p, q.x * p, q.y * p, q.z * p)
}

public func *(p: Float, q: quat) -> quat {
    return q * p
}

public func /(q: quat, p: Float) -> quat {
    return quat( q.w / p, q.x / p, q.y / p, q.z / p)
}

/// Returns the normalized quaternion.
public func normalize(_ q: quat) -> quat {
    let len = length(q)
    if (len <= Float(0)) {
        // Problem
        return quat(1, 0, 0, 0)
    }
    let oneOverLen = Float(1) / len
    return quat(q.w * oneOverLen, q.x * oneOverLen, q.y * oneOverLen, q.z * oneOverLen)
}

/// Returns the length of the quaternion.
public func length(_ q: quat) -> Float {
    return sqrtf( dot(q, q) )
}

/// Returns the q conjugate.
public func conjugate(_ q: quat) -> quat {
    return quat(q.w, -q.x, -q.y, -q.z)
}

/// Returns the q inverse.
public func inverse(_ q: quat) -> quat {
    return conjugate(q) / dot(q, q)
}

public func dot(_ q1: quat, _ q2: quat) -> Float {
    let tmp = float4(q1.x * q2.x, q1.y * q2.y, q1.z * q2.z, q1.w * q2.w)
    return (tmp.x + tmp.y) + (tmp.z + tmp.w)
}

/// Spherical linear interpolation of two quaternions.
/// The interpolation is oriented and the rotation is performed at constant speed.
/// For short path spherical linear interpolation, use the slerp function.
public func mix(_ x: quat, _ y: quat, _ a: Float) -> quat {
    let cosTheta = dot(x, y);

    // Perform a linear interpolation when cosTheta is close to 1 to avoid side effect of sin(angle) becoming a zero denominator
    if (cosTheta > Float(1) - Float(0.0000001)) {

        // Linear interpolation
        return quat( mix(x.w, y.w, a),
                     mix(x.x, y.x, a),
                     mix(x.y, y.y, a),
                     mix(x.z, y.z, a))
    } else {
        // Essential Mathematics, page 467
        let angle = acos(cosTheta)
        return (sin((Float(1) - a) * angle) * x + sin(a * angle) * y) / sin(angle)
    }
}

/// Linear interpolation of two quaternions.
/// The interpolation is oriented.
public func lerp(_ x: quat, _ y: quat, _ a: Float) -> quat {
    return x * (Float(1) - a) + (y * a)
}

/// Spherical linear interpolation of two quaternions.
/// The interpolation always take the short path and the rotation is performed at constant speed.
public func slerp(_ x: quat, _ y: quat, _ a: Float) -> quat {
    var z = y

    var cosTheta = dot(x, y)

    // If cosTheta < 0, the interpolation will take the long way around the sphere.
    // To fix this, one quat must be negated.
    if (cosTheta < Float(0)) {
        z = -y
        cosTheta = -cosTheta
    }

    // Perform a linear interpolation when cosTheta is close to 1 to avoid side effect of sin(angle) becoming a zero denominator
    if (cosTheta > Float(1) - Float(0.0000001)) {
        // Linear interpolation
        return quat( mix(x.w, z.w, a),
                     mix(x.x, z.x, a),
                     mix(x.y, z.y, a),
                     mix(x.z, z.z, a))
    } else {
        // Essential Mathematics, page 467
        let angle = acos(cosTheta)
        return (sin((Float(1) - a) * angle) * x + sin(a * angle) * z) / sin(angle)
    }
}

/// Rotates a quaternion from a vector of 3 components axis and an angle.
public func rotate(q: quat, angle: Float, axis: float3) -> quat {
    var tmp = axis

    // Axis of rotation must be normalised
    let len = length(tmp)
    if (abs(len - Float(1)) > Float(0.001)) {
        let oneOverLen = Float(1) / len
        tmp *= oneOverLen
    }

    let AngleRad = angle
    let Sin = sin(AngleRad * Float(0.5))

    return q * quat(cos(AngleRad * Float(0.5)), tmp.x * Sin, tmp.y * Sin, tmp.z * Sin)
}

/// Returns euler angles, yitch as x, yaw as y, roll as z.
/// The result is expressed in radians if GLM_FORCE_RADIANS is defined or degrees otherwise.
public func eulerAngles(_ x: quat) -> float3 {
    return float3(pitch(x), yaw(x), roll(x))
}

/// Returns roll value of euler angles expressed in radians.
public func roll(_ q: quat) -> Float {
    return Float(atan2(Float(2) * (q.x * q.y + q.w * q.z), q.w * q.w + q.x * q.x - q.y * q.y - q.z * q.z))
}

/// Returns pitch value of euler angles expressed in radians.
public func pitch(_ q: quat) -> Float {
    return Float(atan2(Float(2) * (q.y * q.z + q.w * q.x), q.w * q.w - q.x * q.x - q.y * q.y + q.z * q.z))
}

/// Returns yaw value of euler angles expressed in radians.
public func yaw(_ q: quat) -> Float {
    return asin(Float(-2) * (q.x * q.z - q.w * q.y))
}

/// Converts a quaternion to a 3 * 3 matrix.
public func float3x3_cast(_ q: quat) -> float3x3 {
    var Result = float3x3(1)
    let qxx = q.x * q.x
    let qyy = q.y * q.y
    let qzz = q.z * q.z
    let qxz = q.x * q.z
    let qxy = q.x * q.y
    let qyz = q.y * q.z
    let qwx = q.w * q.x
    let qwy = q.w * q.y
    let qwz = q.w * q.z

    Result[0][0] = 1 - 2 * (qyy + qzz)
    Result[0][1] = 2 * (qxy + qwz)
    Result[0][2] = 2 * (qxz - qwy)

    Result[1][0] = 2 * (qxy - qwz)
    Result[1][1] = 1 - 2 * (qxx + qzz)
    Result[1][2] = 2 * (qyz + qwx)

    Result[2][0] = 2 * (qxz + qwy)
    Result[2][1] = 2 * (qyz - qwx)
    Result[2][2] = 1 - 2 * (qxx + qyy)
    return Result
}

/// Converts a quaternion to a 4 * 4 matrix.
public func float4x4_cast(_ q: quat) -> float4x4 {
    return float4x4(float3x3_cast(q))
}

/// Converts a 3 * 3 matrix to a quaternion.
public func quat_cast(_ m: float3x3) -> quat {
    let fourXSquaredMinus1 = m[0][0] - m[1][1] - m[2][2]
    let fourYSquaredMinus1 = m[1][1] - m[0][0] - m[2][2]
    let fourZSquaredMinus1 = m[2][2] - m[0][0] - m[1][1]
    let fourWSquaredMinus1 = m[0][0] + m[1][1] + m[2][2]

    var biggestIndex = 0
    var fourBiggestSquaredMinus1 = fourWSquaredMinus1

    if fourXSquaredMinus1 > fourBiggestSquaredMinus1 {
        fourBiggestSquaredMinus1 = fourXSquaredMinus1
        biggestIndex = 1
    }
    if fourYSquaredMinus1 > fourBiggestSquaredMinus1 {
        fourBiggestSquaredMinus1 = fourYSquaredMinus1
        biggestIndex = 2
    }
    if fourZSquaredMinus1 > fourBiggestSquaredMinus1 {
        fourBiggestSquaredMinus1 = fourZSquaredMinus1
        biggestIndex = 3
    }

    let biggestVal = sqrt(fourBiggestSquaredMinus1 + Float(1)) * Float(0.5)
    let mult = Float(0.25) / biggestVal

    var Result = quat()
    switch (biggestIndex) {
    case 0:
        Result.w = biggestVal
        Result.x = (m[1][2] - m[2][1]) * mult
        Result.y = (m[2][0] - m[0][2]) * mult
        Result.z = (m[0][1] - m[1][0]) * mult
        break
    case 1:
        Result.w = (m[1][2] - m[2][1]) * mult
        Result.x = biggestVal
        Result.y = (m[0][1] + m[1][0]) * mult
        Result.z = (m[2][0] + m[0][2]) * mult
        break
    case 2:
        Result.w = (m[2][0] - m[0][2]) * mult
        Result.x = (m[0][1] + m[1][0]) * mult
        Result.y = biggestVal
        Result.z = (m[1][2] + m[2][1]) * mult
        break
    case 3:
        Result.w = (m[0][1] - m[1][0]) * mult
        Result.x = (m[2][0] + m[0][2]) * mult
        Result.y = (m[1][2] + m[2][1]) * mult
        Result.z = biggestVal
        break

    default:
        assert(false)
        break
    }
    return Result
}

/// Converts a 4 * 4 matrix to a quaternion.
public func quat_cast(_ m: float4x4) -> quat {
    return quat_cast(float3x3(m))
}

/// Returns the quaternion rotation angle.
public func angle(_ q: quat) -> Float {
    return acos(q.w) * Float(2)
}

/// Returns the q rotation axis.
public func axis(_ q: quat) -> float3 {
    let tmp1 = Float(1) - q.w * q.w
    if (tmp1 <= Float(0)) {
        return float3(0, 0, 1)
    }
    let tmp2 = Float(1) / sqrt(tmp1)
    return float3(q.x * tmp2, q.y * tmp2, q.z * tmp2)
}

/// Build a quaternion from an angle and a normalized axis.
public func angleAxis(angle: Float, axis: float3) -> quat {
    var Result = quat()

    let a = angle
    let s = sin(a * Float(0.5))

    Result.w = cos(a * Float(0.5))
    Result.x = axis.x * s
    Result.y = axis.y * s
    Result.z = axis.z * s
    return Result
}

public struct dquat: ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    public var x: Double
    public var y: Double
    public var z: Double
    public var w: Double

    public init() {
        x = 0
        y = 0
        z = 0
        w = 1
    }
    
    public init(w: Double, v: double3) {
        x = v.x
        y = v.y
        z = v.z
        self.w = w
    }
    
    public init(angle: Double, axis: double3) {
        self = angleAxis(angle: angle, axis: axis)
    }

    public init(_ w: Double, _ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    public init(_ q: dquat) {
        x = q.x
        y = q.y
        z = q.z
        w = q.w
    }

    /// Initialize to a vector with elements taken from `array`.
    ///
    /// - Precondition: `array` must have exactly four elements.
    public init(_ array: [Double]) {
        w = array[0]
        x = array[1]
        y = array[2]
        z = array[3]
    }

    /// Initialize using `arrayLiteral`.
    ///
    /// - Precondition: the array literal must exactly four elements.
    public init(arrayLiteral elements: Double...) {
        w = elements[0]
        x = elements[1]
        y = elements[2]
        z = elements[3]
    }


    /// Create a quaternion from two normalized axis
    /// @see http://lolengine.net/blog/2013/09/18/beautiful-maths-quaternion-from-vectors
    public init(_ u: double3, _ v: double3) {
        let LocalW = cross(u, v)
        let Dot = dot(u, v)
        let q = dquat(1 + Dot, LocalW.x, LocalW.y, LocalW.z)
        self.init(normalize(q))
    }

    public init(_ eulerAngle: double3) {
        let c = cos(eulerAngle * Double(0.5))
        let s = sin(eulerAngle * Double(0.5))

        w = c.x * c.y * c.z + s.x * s.y * s.z
        x = s.x * c.y * c.z - c.x * s.y * s.z
        y = c.x * s.y * c.z + s.x * c.y * s.z
        z = c.x * c.y * s.z - s.x * s.y * c.z
    }

    public init(_ m: double3x3) {
        self.init(dquat_cast(m))
    }

    public init(_ m: double4x4) {
        self.init(dquat_cast(m))
    }

    public var debugDescription: String {
        get {
            return ""
        }
    }
}

prefix public func +(q: dquat) -> dquat {
    return q
}

prefix public func -(q: dquat) -> dquat {
    return dquat( -q.w, -q.x, -q.y, -q.z)
}

public func +(q: dquat, p: dquat) -> dquat {
    return dquat(q.w + p.w, q.x + p.x, q.y + p.y, q.z + p.z)
}

public func *(p: dquat, q: dquat) -> dquat {
    
    let w = p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z
    let x = p.w * q.x + p.x * q.w + p.y * q.z - p.z * q.y
    let y = p.w * q.y + p.y * q.w + p.z * q.x - p.x * q.z
    let z = p.w * q.z + p.z * q.w + p.x * q.y - p.y * q.x
    return dquat(w, x, y, z)
}

public func *(q: dquat, v: double3) -> double3 {
    let QuatVector = double3(q.x, q.y, q.z)
    let uv = cross(QuatVector, v)
    let uuv = cross(QuatVector, uv)

    return v + ((uv * q.w) + uuv) * Double(2)
}

public func *(v: double3, q: dquat) -> double3 {
    return inverse(q) * v
}

public func *(q: dquat, v: double4) -> double4 {
    return double4(q * double3(v), v.w)
}

public func *(v: double4, q: dquat) -> double4 {
    return inverse(q) * v
}

public func *(q: dquat, p: Double) -> dquat {
    return dquat(q.w * p, q.x * p, q.y * p, q.z * p)
}

public func *(p: Double, q: dquat) -> dquat {
    return q * p
}

public func /(q: dquat, p: Double) -> dquat {
    return dquat(q.w / p, q.x / p, q.y / p, q.z / p)
}

/// Returns the normalized quaternion.
public func normalize(_ q: dquat) -> dquat {
    let len = length(q)
    if (len <= Double(0)) {
        // Problem
        return dquat(1, 0, 0, 0)
    }
    let oneOverLen = Double(1) / len
    return dquat(q.w * oneOverLen, q.x * oneOverLen, q.y * oneOverLen, q.z * oneOverLen)
}

/// Returns the length of the quaternion.
public func length(_ q: dquat) -> Double {
    return sqrt(dot(q, q))
}

/// Returns the q conjugate.
public func conjugate(_ q: dquat) -> dquat {
    return dquat(q.w, -q.x, -q.y, -q.z)
}

/// Returns the q inverse.
public func inverse(_ q: dquat) -> dquat {
    return conjugate(q) / dot(q, q)
}

/// Returns dot product of q1 and q2, i.e., q1[0] * q2[0] + q1[1] * q2[1] + ...
public func dot(_ q1: dquat, _ q2: dquat) -> Double {
    let tmp = double4(q1.x * q2.x, q1.y * q2.y, q1.z * q2.z, q1.w * q2.w)
    return (tmp.x + tmp.y) + (tmp.z + tmp.w)
}

/// Spherical linear interpolation of two quaternions.
/// The interpolation is oriented and the rotation is performed at constant speed.
/// For short path spherical linear interpolation, use the slerp function.
public func mix(_ x: dquat, _ y: dquat, _ a: Double) -> dquat {
    let cosTheta = dot(x, y);

    // Perform a linear interpolation when cosTheta is close to 1 to avoid side effect of sin(angle) becoming a zero denominator
    if (cosTheta > Double(1) - Double(0.0000001)) {

        // Linear interpolation
        return dquat( mix(x.w, y.w, a),
                      mix(x.x, y.x, a),
                      mix(x.y, y.y, a),
                      mix(x.z, y.z, a))
    } else {
        // Essential Mathematics, page 467
        let angle = acos(cosTheta)
        return (sin((Double(1) - a) * angle) * x + sin(a * angle) * y) / sin(angle)
    }
}

/// Linear interpolation of two quaternions.
/// The interpolation is oriented.
public func lerp(_ x: dquat, _ y: dquat, _ a: Double) -> dquat {
    return x * (Double(1) - a) + (y * a)
}

/// Spherical linear interpolation of two quaternions.
/// The interpolation always take the short path and the rotation is performed at constant speed.
public func slerp(_ x: dquat, _ y: dquat, _ a: Double) -> dquat {
    var z = y

    var cosTheta = dot(x, y)

    // If cosTheta < 0, the interpolation will take the long way around the sphere.
    // To fix this, one quat must be negated.
    if (cosTheta < Double(0)) {
        z = -y
        cosTheta = -cosTheta
    }

    // Perform a linear interpolation when cosTheta is close to 1 to avoid side effect of sin(angle) becoming a zero denominator
    if (cosTheta > Double(1) - Double(0.0000001)) {
        // Linear interpolation
        return dquat( mix(x.w, z.w, a),
                      mix(x.x, z.x, a),
                      mix(x.y, z.y, a),
                      mix(x.z, z.z, a))
    } else {
        // Essential Mathematics, page 467
        let angle = acos(cosTheta)
        return (sin((Double(1) - a) * angle) * x + sin(a * angle) * z) / sin(angle)
    }
}

/// Rotates a quaternion from a vector of 3 components axis and an angle.
public func rotate(q: dquat, angle: Double, axis: double3) -> dquat {
    var tmp = axis

    // Axis of rotation must be normalised
    let len = length(tmp)
    if (abs(len - Double(1)) > Double(0.001)) {
        let oneOverLen = Double(1) / len
        tmp *= oneOverLen
    }

    let AngleRad = angle
    let Sin = sin(AngleRad * Double(0.5))

    return q * dquat(cos(AngleRad * Double(0.5)), tmp.x * Sin, tmp.y * Sin, tmp.z * Sin)
}

/// Returns euler angles, yitch as x, yaw as y, roll as z.
/// The result is expressed in radians if GLM_FORCE_RADIANS is defined or degrees otherwise.
public func eulerAngles(_ x: dquat) -> double3 {
    return double3(pitch(x), yaw(x), roll(x))
}

/// Returns roll value of euler angles expressed in radians.
public func roll(_ q: dquat) -> Double {
    return Double(atan2(Double(2) * (q.x * q.y + q.w * q.z), q.w * q.w + q.x * q.x - q.y * q.y - q.z * q.z))
}

/// Returns pitch value of euler angles expressed in radians.
public func pitch(_ q: dquat) -> Double {
    return Double(atan2(Double(2) * (q.y * q.z + q.w * q.x), q.w * q.w - q.x * q.x - q.y * q.y + q.z * q.z))
}

/// Returns yaw value of euler angles expressed in radians.
public func yaw(_ q: dquat) -> Double {
    return asin(Double(-2) * (q.x * q.z - q.w * q.y))
}

/// Converts a quaternion to a 3 * 3 matrix.
public func double3x3_cast(_ q: dquat) -> double3x3 {
    var Result = double3x3(1)
    let qxx = q.x * q.x
    let qyy = q.y * q.y
    let qzz = q.z * q.z
    let qxz = q.x * q.z
    let qxy = q.x * q.y
    let qyz = q.y * q.z
    let qwx = q.w * q.x
    let qwy = q.w * q.y
    let qwz = q.w * q.z

    Result[0][0] = 1 - 2 * (qyy + qzz)
    Result[0][1] = 2 * (qxy + qwz)
    Result[0][2] = 2 * (qxz - qwy)

    Result[1][0] = 2 * (qxy - qwz)
    Result[1][1] = 1 - 2 * (qxx + qzz)
    Result[1][2] = 2 * (qyz + qwx)

    Result[2][0] = 2 * (qxz + qwy)
    Result[2][1] = 2 * (qyz - qwx)
    Result[2][2] = 1 - 2 * (qxx + qyy)
    return Result
}

/// Converts a quaternion to a 4 * 4 matrix.
public func double4x4_cast(_ q: dquat) -> double4x4 {
    return double4x4(double3x3_cast(q))
}

/// Converts a 3 * 3 matrix to a quaternion.
public func dquat_cast(_ m: double3x3) -> dquat {
    let fourXSquaredMinus1 = m[0][0] - m[1][1] - m[2][2]
    let fourYSquaredMinus1 = m[1][1] - m[0][0] - m[2][2]
    let fourZSquaredMinus1 = m[2][2] - m[0][0] - m[1][1]
    let fourWSquaredMinus1 = m[0][0] + m[1][1] + m[2][2]

    var biggestIndex = 0
    var fourBiggestSquaredMinus1 = fourWSquaredMinus1

    if fourXSquaredMinus1 > fourBiggestSquaredMinus1 {
        fourBiggestSquaredMinus1 = fourXSquaredMinus1
        biggestIndex = 1
    }
    if fourYSquaredMinus1 > fourBiggestSquaredMinus1 {
        fourBiggestSquaredMinus1 = fourYSquaredMinus1
        biggestIndex = 2
    }
    if fourZSquaredMinus1 > fourBiggestSquaredMinus1 {
        fourBiggestSquaredMinus1 = fourZSquaredMinus1
        biggestIndex = 3
    }

    let biggestVal = sqrt(fourBiggestSquaredMinus1 + Double(1)) * Double(0.5)
    let mult = Double(0.25) / biggestVal

    var Result = dquat()
    switch (biggestIndex) {
    case 0:
        Result.w = biggestVal
        Result.x = (m[1][2] - m[2][1]) * mult
        Result.y = (m[2][0] - m[0][2]) * mult
        Result.z = (m[0][1] - m[1][0]) * mult
        break
    case 1:
        Result.w = (m[1][2] - m[2][1]) * mult
        Result.x = biggestVal
        Result.y = (m[0][1] + m[1][0]) * mult
        Result.z = (m[2][0] + m[0][2]) * mult
        break
    case 2:
        Result.w = (m[2][0] - m[0][2]) * mult
        Result.x = (m[0][1] + m[1][0]) * mult
        Result.y = biggestVal
        Result.z = (m[1][2] + m[2][1]) * mult
        break
    case 3:
        Result.w = (m[0][1] - m[1][0]) * mult
        Result.x = (m[2][0] + m[0][2]) * mult
        Result.y = (m[1][2] + m[2][1]) * mult
        Result.z = biggestVal
        break

    default:
        assert(false)
        break
    }
    return Result
}

/// Converts a 4 * 4 matrix to a quaternion.
public func dquat_cast(_ m: double4x4) -> dquat {
    return dquat_cast(double3x3(m))
}

/// Returns the quaternion rotation angle.
public func angle(_ q: dquat) -> Double {
    return acos(q.w) * Double(2)
}

/// Returns the q rotation axis.
public func axis(_ q: dquat) -> double3 {
    let tmp1 = Double(1) - q.w * q.w
    if (tmp1 <= Double(0)) {
        return double3(0, 0, 1)
    }
    let tmp2 = Double(1) / sqrt(tmp1)
    return double3(q.x * tmp2, q.y * tmp2, q.z * tmp2)
}

/// Build a quaternion from an angle and a normalized axis.
public func angleAxis(angle: Double, axis: double3) -> dquat {
    var Result = dquat()

    let a = angle
    let s = sin(a * Double(0.5))

    Result.w = cos(a * Double(0.5))
    Result.x = axis.x * s
    Result.y = axis.y * s
    Result.z = axis.z * s
    return Result
}
