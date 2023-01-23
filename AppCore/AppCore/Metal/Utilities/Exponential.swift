
import Foundation
import simd

// MARK: pow

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: SIMD2<Float>, _ exp: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(pow(base[0], exp[0]), pow(base[1], exp[1]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: SIMD3<Float>, _ exp: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: SIMD4<Float>, _ exp: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]), pow(base[3], exp[3]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: SIMD2<Double>, _ exp: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(pow(base[0], exp[0]), pow(base[1], exp[1]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: SIMD3<Double>, _ exp: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]))
}

/// Returns 'base' raised to the power 'exp'.
public func pow(_ base: SIMD4<Double>, _ exp: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(pow(base[0], exp[0]), pow(base[1], exp[1]), pow(base[2], exp[2]), pow(base[3], exp[3]))
}

// MARK: exp

/// Returns the natural exponentiation of x, i.e., e^x.
public func exp(_ x: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(exp(x[0]), exp(x[1]))
}

/// Returns the natural exponentiation of x, i.e., e^x.
public func exp(_ x: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(exp(x[0]), exp(x[1]), exp(x[2]))
}

/// Returns the natural exponentiation of x, i.e., e^x.
public func exp(_ x: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(exp(x[0]), exp(x[1]), exp(x[2]), exp(x[3]))
}

/// Returns the natural exponentiation of x, i.e., e^x.

public func exp(_ x: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(exp(x[0]), exp(x[1]))
}

/// Returns the natural exponentiation of x, i.e., e^x.

public func exp(_ x: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(exp(x[0]), exp(x[1]), exp(x[2]))
}

/// Returns the natural exponentiation of x, i.e., e^x.

public func exp(_ x: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(exp(x[0]), exp(x[1]), exp(x[2]), exp(x[3]))
}

// MARK: log

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(log(v[0]), log(v[1]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(log(v[0]), log(v[1]), log(v[2]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(log(v[0]), log(v[1]), log(v[2]), log(v[3]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(log(v[0]), log(v[1]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(log(v[0]), log(v[1]), log(v[2]))
}

/// Returns the natural logarithm of v, i.e.,
/// Returns the value y which satisfies the equation x = e^y.
/// Results are undefined if v <= 0.

public func log(_ v: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(log(v[0]), log(v[1]), log(v[2]), log(v[3]))
}

// MARK: exp2

/// Returns 2 raised to the v power.

public func exp2(_ v: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(exp2(v[0]), exp2(v[1]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(exp2(v[0]), exp2(v[1]), exp2(v[2]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(exp2(v[0]), exp2(v[1]), exp2(v[2]), exp2(v[3]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(exp2(v[0]), exp2(v[1]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(exp2(v[0]), exp2(v[1]), exp2(v[2]))
}

/// Returns 2 raised to the v power.

public func exp2(_ v: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(exp2(v[0]), exp2(v[1]), exp2(v[2]), exp2(v[3]))
}

// MARK: log2

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(log2(x[0]), log2(x[1]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(log2(x[0]), log2(x[1]), log2(x[2]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(log2(x[0]), log2(x[1]), log2(x[2]), log2(x[3]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(log2(x[0]), log2(x[1]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(log2(x[0]), log2(x[1]), log2(x[2]))
}

/// Returns the base 2 log of x, i.e., returns the value y,
/// which satisfies the equation x = 2 ^ y.

public func log2(_ x: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(log2(x[0]), log2(x[1]), log2(x[2]), log2(x[3]))
}

// MARK: sqrt

/// Returns the positive square root of v.

public func sqrt(_ v: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(sqrt(v[0]), sqrt(v[1]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]), sqrt(v[3]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(sqrt(v[0]), sqrt(v[1]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]))
}

/// Returns the positive square root of v.

public func sqrt(_ v: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(sqrt(v[0]), sqrt(v[1]), sqrt(v[2]), sqrt(v[3]))
}

// MARK: inversesqrt

/// Returns the reciprocal of the positive square root of v.

public func inversesqrt(_ v: SIMD2<Float>) -> SIMD2<Float> {
    return SIMD2<Float>(repeating: 1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.

public func inversesqrt(_ v: SIMD3<Float>) -> SIMD3<Float> {
    return SIMD3<Float>(repeating: 1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.

public func inversesqrt(_ v: SIMD4<Float>) -> SIMD4<Float> {
    return SIMD4<Float>(repeating: 1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.
public func inversesqrt(_ v: SIMD2<Double>) -> SIMD2<Double> {
    return SIMD2<Double>(repeating: 1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.
public func inversesqrt(_ v: SIMD3<Double>) -> SIMD3<Double> {
    return SIMD3<Double>(repeating: 1) / sqrt(v)
}

/// Returns the reciprocal of the positive square root of v.
public func inversesqrt(_ v: SIMD4<Double>) -> SIMD4<Double> {
    return SIMD4<Double>(repeating: 1) / sqrt(v)
}
