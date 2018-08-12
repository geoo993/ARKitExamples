
import Foundation
import simd

// MARK: pow

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: float2, _ exp: float2) -> float2 {
    return float2(pow(base[0], exp[0]), pow(base[1], exp[1]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: float3, _ exp: float3) -> float3 {
    return float3(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: float4, _ exp: float4) -> float4 {
    return float4(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]), pow(base[3], exp[3]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: double2, _ exp: double2) -> double2 {
    return double2(pow(base[0], exp[0]), pow(base[1], exp[1]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: double3, _ exp: double3) -> double3 {
    return double3(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: double4, _ exp: double4) -> double4 {
    return double4(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]), pow(base[3], exp[3]))
}

// MARK: exp

/// Returns the natural exponentiation of x, i.e., e^x.
public func exp(_ x: float2) -> float2 {
    return float2(exp(x[0]), exp(x[1]))
}

/// Returns the natural exponentiation of x, i.e., e^x.
public func exp(_ x: float3) -> float3 {
    return float3(exp(x[0]), exp(x[1]), exp(x[2]))
}

/// Returns the natural exponentiation of x, i.e., e^x.
public func exp(_ x: float4) -> float4 {
    return float4(exp(x[0]), exp(x[1]), exp(x[2]), exp(x[3]))
}

/// Returns the natural exponentiation of x, i.e., e^x.

public func exp(_ x: double2) -> double2 {
    return double2(exp(x[0]), exp(x[1]))
}

/// Returns the natural exponentiation of x, i.e., e^x.

public func exp(_ x: double3) -> double3 {
    return double3(exp(x[0]), exp(x[1]), exp(x[2]))
}

/// Returns the natural exponentiation of x, i.e., e^x.

public func exp(_ x: double4) -> double4 {
    return double4(exp(x[0]), exp(x[1]), exp(x[2]), exp(x[3]))
}

// MARK: log

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: float2) -> float2 {
    return float2(log(v[0]), log(v[1]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: float3) -> float3 {
    return float3(log(v[0]), log(v[1]), log(v[2]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: float4) -> float4 {
    return float4(log(v[0]), log(v[1]), log(v[2]), log(v[3]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: double2) -> double2 {
    return double2(log(v[0]), log(v[1]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: double3) -> double3 {
    return double3(log(v[0]), log(v[1]), log(v[2]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: double4) -> double4 {
    return double4(log(v[0]), log(v[1]), log(v[2]), log(v[3]))
}

// MARK: exp2

/// Returns 2 raised to the v power.

public func exp2(_ v: float2) -> float2 {
    return float2(exp2(v[0]), exp2(v[1]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: float3) -> float3 {
    return float3(exp2(v[0]), exp2(v[1]), exp2(v[2]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: float4) -> float4 {
    return float4(exp2(v[0]), exp2(v[1]), exp2(v[2]), exp2(v[3]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: double2) -> double2 {
    return double2(exp2(v[0]), exp2(v[1]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: double3) -> double3 {
    return double3(exp2(v[0]), exp2(v[1]), exp2(v[2]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: double4) -> double4 {
    return double4(exp2(v[0]), exp2(v[1]), exp2(v[2]), exp2(v[3]))
}

// MARK: log2

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: float2) -> float2 {
    return float2(log2(x[0]), log2(x[1]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: float3) -> float3 {
    return float3(log2(x[0]), log2(x[1]), log2(x[2]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: float4) -> float4 {
    return float4(log2(x[0]), log2(x[1]), log2(x[2]), log2(x[3]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: double2) -> double2 {
    return double2(log2(x[0]), log2(x[1]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: double3) -> double3 {
    return double3(log2(x[0]), log2(x[1]), log2(x[2]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: double4) -> double4 {
    return double4(log2(x[0]), log2(x[1]), log2(x[2]), log2(x[3]))
}

// MARK: sqrt

/// Returns the positive square root of v.

public func sqrt(_ v: float2) -> float2 {
    return float2(sqrt(v[0]), sqrt(v[1]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: float3) -> float3 {
    return float3(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: float4) -> float4 {
    return float4(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]), sqrt(v[3]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: double2) -> double2 {
    return double2(sqrt(v[0]), sqrt(v[1]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: double3) -> double3 {
    return double3(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: double4) -> double4 {
    return double4(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]), sqrt(v[3]))
}

// MARK: inversesqrt

/// Returns the reciprocal of the positive square root of v.

public func inversesqrt(_ v: float2) -> float2 {
    return float2(1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.

public func inversesqrt(_ v: float3) -> float3 {
    return float3(1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.

public func inversesqrt(_ v: float4) -> float4 {
    return float4(1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.
public func inversesqrt(_ v: double2) -> double2 {
    return double2(1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.
public func inversesqrt(_ v: double3) -> double3 {
    return double3(1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.
public func inversesqrt(_ v: double4) -> double4 {
    return double4(1) / sqrt(v)
}
