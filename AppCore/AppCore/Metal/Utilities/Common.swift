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
public func round(x: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(round(x[0]), round(x[1]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(round(x[0]), round(x[1]), round(x[2]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(round(x[0]), round(x[1]), round(x[2]), round(x[3]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(round(x[0]), round(x[1]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(round(x[0]), round(x[1]), round(x[2]))
}

/// Returns a value equal to the nearest integer to x.
public func round(x: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(round(x[0]), round(x[1]), round(x[2]), round(x[3]))
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

public func roundEven(x: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(roundEven(x: x[0]), roundEven(x: x[1]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(roundEven(x: x[0]), roundEven(x: x[1]), roundEven(x: x[2]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(roundEven(x: x[0]), roundEven(x: x[1]), roundEven(x: x[2]), roundEven(x: x[3]))
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

public func roundEven(x: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(roundEven(x:x[0]), roundEven(x: x[1]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(roundEven(x:x[0]), roundEven(x:x[1]), roundEven(x:x[2]))
}

/// Returns a value equal to the nearest integer to x.
/// A fractional part of 0.5 will round toward the nearest even
/// integer. (Both 3.5 and 4.5 for x will return 4.0.)

public func roundEven(x: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(roundEven(x:x[0]), roundEven(x:x[1]), roundEven(x:x[2]), roundEven(x:x[3]))
}

// MARK: - mod

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: Float, _ y: Float) -> Float {
    return x-y * floor(x/y)
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD2<Float>, _ y: Float) -> SIMD2<Float> {
    return SIMD2<Float>(mod(x[0], y), mod(x[1], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD3<Float>, _ y: Float) -> SIMD3<Float> {
    return SIMD3<Float>(mod(x[0], y), mod(x[1], y), mod(x[2], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD4<Float>, _ y: Float) -> SIMD4<Float> {
    return SIMD4<Float>(mod(x[0], y), mod(x[1], y), mod(x[2], y), mod(x[3], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD2<Float>, _ y: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(mod(x[0], y[0]), mod(x[1], y[1]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD3<Float>, _ y: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD4<Float>, _ y: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]), mod(x[3], y[3]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: Double, _ y: Double) -> Double {
    return x-y * floor(x/y)
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.

public func mod(_ x: SIMD2<Double>, _ y: Double) -> SIMD2<Double> {
    return SIMD2<Double>(mod(x[0], y), mod(x[1], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: SIMD3<Double>, _ y: Double) -> SIMD3<Double> {
    return SIMD3<Double>(mod(x[0], y), mod(x[1], y), mod(x[2], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: SIMD4<Double>, _ y: Double) -> SIMD4<Double> {
    return SIMD4<Double>(mod(x[0], y), mod(x[1], y), mod(x[2], y), mod(x[3], y))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: SIMD2<Double>, _ y: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(mod(x[0], y[0]), mod(x[1], y[1]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: SIMD3<Double>, _ y: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]))
}

/// Modulus. Returns x - y * floor(x / y)
/// for each component in x using the floating point value y.
public func mod(_ x: SIMD4<Double>, _ y: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]), mod(x[3], y[3]))
}

// MARK: - modf

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.
public func modf(x: SIMD2<Float>) -> (SIMD2<Float>, SIMD2<Float>) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: SIMD3<Float>) -> (SIMD3<Float>, SIMD3<Float>) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: SIMD4<Float>) -> (SIMD4<Float>, SIMD4<Float>) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: SIMD2<Double>) -> (SIMD2<Double>, SIMD2<Double>) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: SIMD3<Double>) -> (SIMD3<Double>, SIMD3<Double>) {
    let y = trunc(x)
    return (y, x - y)
}

/// Returns the integer (as a whole number floating point value) and fractional
/// part of x. Both the return values will have the same sign as x.

public func modf(x: SIMD4<Double>) -> (SIMD4<Double>, SIMD4<Double>) {
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
public func fma(a: SIMD2<Float>, b: SIMD2<Float>, c: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]))
}

/// Computes and returns a * b + c.
public func fma(a: SIMD3<Float>, b: SIMD3<Float>, c: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]))
}

/// Computes and returns a * b + c.
public func fma(a: SIMD4<Float>, b: SIMD4<Float>, c: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]), fma(a[3], b[3], c[3]))
}

/// Computes and returns a * b + c.
public func fma(a: SIMD2<Double>, b: SIMD2<Double>, c: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]))
}

/// Computes and returns a * b + c.
public func fma(a: SIMD3<Double>, b: SIMD3<Double>, c: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]))
}

/// Computes and returns a * b + c.
public func fma(a: SIMD4<Double>, b: SIMD4<Double>, c: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(fma(a[0], b[0], c[0]), fma(a[1], b[1], c[1]), fma(a[2], b[2], c[2]), fma(a[3], b[3], c[3]))
}

// MARK: - frexp

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: SIMD2<Float>) -> (SIMD2<Float>, SIMD2<Int32>) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    return (SIMD2<Float>(f1.0, f2.0), SIMD2<Int32>(Int32(f1.1), Int32(f2.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: SIMD3<Float>) -> (SIMD3<Float>, SIMD3<Int32>) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    return (SIMD3<Float>(f1.0, f2.0, f3.0), SIMD3<Int32>(Int32(f1.1), Int32(f2.1), Int32(f3.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: SIMD4<Float>) -> (SIMD4<Float>, SIMD4<Int32>) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    let f4 = frexp(x[3])
    return (SIMD4<Float>(f1.0, f2.0, f3.0, f4.0), SIMD4<Int32>(Int32(f1.1), Int32(f2.1), Int32(f3.1), Int32(f4.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: SIMD2<Double>) -> (SIMD2<Double>, SIMD2<Int32>) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    return (SIMD2<Double>(f1.0, f2.0), SIMD2<Int32>(Int32(f1.1), Int32(f2.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: SIMD3<Double>) -> (SIMD3<Double>, SIMD3<Int32>) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    return (SIMD3<Double>(f1.0, f2.0, f3.0), SIMD3<Int32>(Int32(f1.1), Int32(f2.1), Int32(f3.1)))
}

/// Splits x into a floating-point significand in the range
/// [0.5, 1.0) and an integral exponent of two, such that:
/// x = significand * exp(2, exponent)
public func frexp(x: SIMD4<Double>) -> (SIMD4<Double>, SIMD4<Int32>) {
    let f1 = frexp(x[0])
    let f2 = frexp(x[1])
    let f3 = frexp(x[2])
    let f4 = frexp(x[3])
    return (SIMD4<Double>(f1.0, f2.0, f3.0, f4.0), SIMD4<Int32>(Int32(f1.1), Int32(f2.1), Int32(f3.1), Int32(f4.1)))
}

// MARK: - ldexp

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: SIMD2<Float>, exp: SIMD2<Int32>) -> SIMD2<Float> {
    return SIMD2<Float>(scalbn(x[0], Int(exp[0])), scalbn(x[1], Int(exp[1])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: SIMD3<Float>, exp: SIMD3<Int32>) -> SIMD3<Float> {
    return SIMD3<Float>(scalbn(x[0], Int(exp[0])), scalbn(x[1], Int(exp[1])), scalbn(x[2], Int(exp[2])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: SIMD4<Float>, exp: SIMD4<Int32>) -> SIMD4<Float> {
    return SIMD4<Float>(scalbn(x[0], Int(exp[0])), scalbn(x[1], Int(exp[1])), scalbn(x[2], Int(exp[2])), scalbn(x[3], Int(exp[3])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: SIMD2<Double>, exp: SIMD2<Int32>) -> SIMD2<Double> {
    return SIMD2<Double>(scalbn(x[0], Int(exp[0])), scalbn(x[1], Int(exp[1])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: SIMD3<Double>, exp: SIMD3<Int32>) -> SIMD3<Double> {
    return SIMD3<Double>(scalbn(x[0], Int(exp[0])), scalbn(x[1], Int(exp[1])), scalbn(x[2], Int(exp[2])))
}

/// Builds a floating-point number from x and the
/// corresponding integral exponent of two in exp, returning:
/// significand * exp(2, exponent)
public func ldexp(x: SIMD4<Double>, exp: SIMD4<Int32>) -> SIMD4<Double> {
    return SIMD4<Double>(scalbn(x[0], Int(exp[0])), scalbn(x[1], Int(exp[1])), scalbn(x[2], Int(exp[2])), scalbn(x[3], Int(exp[3])))
}
