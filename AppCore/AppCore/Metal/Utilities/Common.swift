import Foundation
import simd

// MARK: clamp

/// Clamp `x` to the range [`min`, max]. If lane of `x` is
/// NaN, the result is `min`.
public func clamp(value: Float, lower: Float, upper: Float) -> Float {
    return min(max(value, lower), upper)
}

/// Clamp `x` to the range [`min`, max]. If lane of `x` is
/// NaN, the result is `min`.
public func clamp(value: Double, lower: Double, upper: Double) -> Double {
    return min(max(value, lower), upper)
}

// MARK: - fract

/// `x - floor(x)`, clamped to lie in the range [0,1).  Without this clamp step,
/// the result would be 1.0 when `x` is a very small negative number, which may
/// result in out-of-bounds table accesses in common usage.

public func fract(x: Float) -> Float {
    return clamp(value: x - floor(x), lower: 0.0, upper: 1.0)
}

/// `x - floor(x)`, clamped to lie in the range [0,1).  Without this clamp step,
/// the result would be 1.0 when `x` is a very small negative number, which may
/// result in out-of-bounds table accesses in common usage.

public func fract(x: Double) -> Double {
    return clamp(value:x - floor(x), lower: 0.0, upper: 1.0)
}

// MARK: - round

/// Returns a value equal to the nearest integer to x.
public func round(x: float2) -> float2 {
    return float2(round(x[0]), round(x[1]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: float3) -> float3 {
    return float3(round(x[0]), round(x[1]), round(x[2]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: float4) -> float4 {
    return float4(round(x[0]), round(x[1]), round(x[2]), round(x[3]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: double2) -> double2 {
    return double2(round(x[0]), round(x[1]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: double3) -> double3 {
    return double3(round(x[0]), round(x[1]), round(x[2]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: double4) -> double4 {
    return double4(round(x[0]), round(x[1]), round(x[2]), round(x[3]))
}

// MARK: - roundEven

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: Float) -> Float {
    let fractionalPart = fract(x: x)
    let integer = Int(x)
    let integerPart = Float(integer)
    
    if(fractionalPart > 0.5 || fractionalPart < 0.5) {
        return round(x)
    } else if ((integer % 2) == 0) {
        return integerPart
    } else if (x <= 0) {
        return integerPart - 1
    } else {
        return integerPart + 1
    }
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: float2) -> float2 {
    return float2(roundEven(x: x[0]), roundEven(x: x[1]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: float3) -> float3 {
    return float3(roundEven(x: x[0]), roundEven(x: x[1]), roundEven(x: x[2]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: float4) -> float4 {
    return float4(roundEven(x: x[0]), roundEven(x: x[1]), roundEven(x: x[2]), roundEven(x: x[3]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: Double) -> Double {
    let fractionalPart = fract(x: x)
    let integer = Int(x)
    let integerPart = Double(integer)
    
    if(fractionalPart > 0.5 || fractionalPart < 0.5) {
        return round(x)
    } else if ((integer % 2) == 0) {
        return integerPart
    } else if (x <= 0) {
        return integerPart - 1
    } else {
        return integerPart + 1
    }
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: double2) -> double2 {
    return double2(roundEven(x:x[0]), roundEven(x: x[1]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: double3) -> double3 {
    return double3(roundEven(x:x[0]), roundEven(x:x[1]), roundEven(x:x[2]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: double4) -> double4 {
    return double4(roundEven(x:x[0]), roundEven(x:x[1]), roundEven(x:x[2]), roundEven(x:x[3]))
}

// MARK: - mod

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: Float, _ y: Float) -> Float {
    return x-y * floor(x/y)
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: float2, _ y: Float) -> float2 {
    return float2(mod(x[0], y), mod(x[1], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: float3, _ y: Float) -> float3 {
    return float3(mod(x[0], y), mod(x[1], y), mod(x[2], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: float4, _ y: Float) -> float4 {
    return float4(mod(x[0], y), mod(x[1], y), mod(x[2], y), mod(x[3], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: float2, _ y: float2) -> float2 {
    return float2(mod(x[0], y[0]), mod(x[1], y[1]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: float3, _ y: float3) -> float3 {
    return float3(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: float4, _ y: float4) -> float4 {
    return float4(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]), mod(x[3], y[3]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: Double, _ y: Double) -> Double {
    return x-y * floor(x/y)
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: double2, _ y: Double) -> double2 {
    return double2(mod(x[0], y), mod(x[1], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: double3, _ y: Double) -> double3 {
    return double3(mod(x[0], y), mod(x[1], y), mod(x[2], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: double4, _ y: Double) -> double4 {
    return double4(mod(x[0], y), mod(x[1], y), mod(x[2], y), mod(x[3], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: double2, _ y: double2) -> double2 {
    return double2(mod(x[0], y[0]), mod(x[1], y[1]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: double3, _ y: double3) -> double3 {
    return double3(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: double4, _ y: double4) -> double4 {
    return double4(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]), mod(x[3], y[3]))
}

// MARK: - modf

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.
public func modf(x: float2) -> (float2, float2) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: float3) -> (float3, float3) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: float4) -> (float4, float4) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: double2) -> (double2, double2) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: double3) -> (double3, double3) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: double4) -> (double4, double4) {
    let y = trunc(x)
    return (y, x - y)
}

// MARK: - mix

/// Returns x * (1.0 - t) + y * t, i.e., the linear blend of
/// x and y using the floating-point value a.
/// The value for t is not restricted to the range [0, 1].
public func mix(_ x: Float, _ y: Float, _ t: Float) -> Float {
    return x + t * (y - x)
}

/// Returns x * (1.0 - t) + y * t, i.e., the linear blend of
/// x and y using the floating-point value a.
/// The value for t is not restricted to the range [0, 1].
public func mix(_ x: Double, _ y: Double, _ t: Double) -> Double {
    return x + t * (y - x)
}

// MARK: - smoothstep

/// Returns 0.0 if x <= edge0 and 1.0 if x >= edge1 and
/// performs smooth Hermite interpolation between 0 and 1
/// when edge0 < x < edge1. This is useful in cases where
/// you would want a threshold function with a smooth

public func smoothstep(x: Float, edge0: Float, edge1: Float) -> Float {
    let t = clamp(value: (x - edge0) / (edge1 - edge0), lower: 0, upper: 1)
    return t * t * (3 - 2 * t);
}

/// Returns 0.0 if x <= edge0 and 1.0 if x >= edge1 and
/// performs smooth Hermite interpolation between 0 and 1
/// when edge0 < x < edge1. This is useful in cases where
/// you would want a threshold function with a smooth
public func smoothstep(x: Double, edge0: Double, edge1: Double) -> Double {
    let t = clamp (value: (x - edge0) / (edge1 - edge0), lower: 0, upper: 1)
    return t * t * (3 - 2 * t);
}

// MARK: - fma

/// Computes and returns a * b + c.
public func fma(a: float2, b: float2, c: float2) -> float2 {
    return float2(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]))
}

/// Computes and returns a * b + c.
public func fma(a: float3, b: float3, c: float3) -> float3 {
    return float3(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]))
}

/// Computes and returns a * b + c.
public func fma(a: float4, b: float4, c: float4) -> float4 {
    return float4(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]), fma(a[3], b[3], c[3]))
}

/// Computes and returns a * b + c.
public func fma(a: double2, b: double2, c: double2) -> double2 {
    return double2(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]))
}

/// Computes and returns a * b + c.
public func fma(a: double3, b: double3, c: double3) -> double3 {
    return double3(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]))
}

/// Computes and returns a * b + c.
public func fma(a: double4, b: double4, c: double4) -> double4 {
    return double4(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]), fma(a[3], b[3], c[3]))
}

// MARK: - frexp

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: float2) -> (float2, int2) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    return (float2(f1.0, f2.0), int2(Int32(f1.1), Int32(f2.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: float3) -> (float3, int3) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    return (float3(f1.0, f2.0, f3.0), int3(Int32(f1.1), Int32(f2.1), Int32(f3.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: float4) -> (float4, int4) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    let f4 = frexp(x[3])
    return (float4(f1.0, f2.0, f3.0, f4.0), int4(Int32(f1.1), Int32(f2.1), Int32(f3.1), Int32(f4.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: double2) -> (double2, int2) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    return (double2(f1.0, f2.0), int2(Int32(f1.1), Int32(f2.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: double3) -> (double3, int3) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    return (double3(f1.0, f2.0, f3.0), int3(Int32(f1.1), Int32(f2.1), Int32(f3.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: double4) -> (double4, int4) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    let f4 = frexp(x[3])
    return (double4(f1.0, f2.0, f3.0, f4.0), int4(Int32(f1.1), Int32(f2.1), Int32(f3.1), Int32(f4.1)))
}

// MARK: - ldexp

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: float2, exp: int2) -> float2 {
    return float2(ldexp(x[0], Int(exp[0])), ldexp(x[1], Int(exp[1])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: float3, exp: int3) -> float3 {
    return float3(ldexp(x[0], Int(exp[0])), ldexp(x[1], Int(exp[1])), ldexp(x[2], Int(exp[2])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: float4, exp: int4) -> float4 {
    return float4(ldexp(x[0], Int(exp[0])), ldexp(x[1], Int(exp[1])), ldexp(x[2], Int(exp[2])), ldexp(x[3], Int(exp[3])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: double2, exp: int2) -> double2 {
    return double2(ldexp(x[0], Int(exp[0])), ldexp(x[1], Int(exp[1])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: double3, exp: int3) -> double3 {
    return double3(ldexp(x[0], Int(exp[0])), ldexp(x[1], Int(exp[1])), ldexp(x[2], Int(exp[2])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: double4, exp: int4) -> double4 {
    return double4(ldexp(x[0], Int(exp[0])), ldexp(x[1], Int(exp[1])), ldexp(x[2], Int(exp[2])), ldexp(x[3], Int(exp[3])))
}
