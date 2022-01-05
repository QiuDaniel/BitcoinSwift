//
//  ModularInverse.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import BigInt

/**
 ModularInverse
 */
func mod<T: BinaryInteger>(_ number: T, modulus: T) -> T {
    var mod = number % modulus
    if mod < 0 {
        mod = mod + modulus
    }
    guard mod >= 0 else { fatalError("Negative Value") }
    return mod
}

func mod<T: BinaryInteger>(expression: () -> T, modulus: T) -> T {
    return mod(expression(), modulus: modulus)
}

/// Equivalence to Python's pow method
func pow(_ base: BigNumber, _ exponent: BigNumber, _ modulus: BigNumber) -> BigNumber {
    return base.power(exponent, modulus: modulus)
}

func divide<T: BinaryInteger>(_ x: T, by y: T, mod p: T) -> T {
    let x = x > 0 ? x : x + p
    let y = y > 0 ? y : y + p
    let euclideanResult = extendedGreatestCommonDivisor(y, p)
    let inverse = euclideanResult.bézoutCoefficients.0
    return mod(inverse * x, modulus: p)
}

struct ExtendedEuclideanAlgorithmResult<T: BinaryInteger> {
    
    /// Greatest Common Divisor
    let gcd: T
    let bézoutCoefficients: (T, T)
    let quotientsByTheGCD: (T, T)
}

/// https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
func extendedGreatestCommonDivisor<T: BinaryInteger>(_ a: T, _ b: T) -> ExtendedEuclideanAlgorithmResult<T> {
    
    var s: T = 0
    var oldS: T = 1
    
    var t: T = 1
    var oldT: T = 0
    
    var r: T = b
    var oldR: T = a
    
    while r != 0 {
        let q = oldR.quotientAndRemainder(dividingBy: r).quotient
        (oldR, r) = (r, oldR - q * r)
        (oldS, s) = (s, oldS - q * s)
        (oldT, t) = (t, oldT - q * t)
        
    }
    let bézoutCoefficients = (oldS, oldT)
    let gcd = oldR
    let quotientsByTheGCD = (t, s)
    return ExtendedEuclideanAlgorithmResult(
        gcd: gcd,
        bézoutCoefficients: bézoutCoefficients,
        quotientsByTheGCD: quotientsByTheGCD
    )
}

func ceilLog2(_ x: BigUInt) -> BigUInt {
    if x == 0 {
        return 0
    }
    guard x > 1 else {
        return 0
    }
    var y: BigUInt = x - 1
    var r: BigUInt = 0
    while y > 0 {
        y >>= 1
        r += 1
    }
    return r
}
