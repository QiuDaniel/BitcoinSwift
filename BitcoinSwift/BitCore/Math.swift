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

/**
 SquareRoot copy from EllipticCurveKit
 */

func legendreSymbol(_ n: BigNumber, modulus p: BigNumber) -> BigNumber {
    let legendreSymbol = n.power((p - 1)/2, modulus: p)
    if legendreSymbol == p - 1 {
        return -1
    }
    guard (legendreSymbol == 0 || legendreSymbol == 1) else { fatalError() }
    return legendreSymbol
}

/// https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm#The_algorithm
func tonelliShanks(_ n: BigNumber, modulus p: BigNumber) -> [BigNumber]? {
    var q, s, z, c, b, r, t, m, i: BigNumber
    
    // Step 1: By factoring out powers of 2, find Q and S such that p^d - 1 = Q 2^S with Q odd
    s = 0
    q = p - 1
    while q % 2 == 0 {
        s += 1
        q /= 2
    }
    
    if s == 1 {
        r = n.power((p + 1) / 4, modulus: p)
        if r.power(2, modulus: p) == n {
            return [r, p - r]
        }
    }
    
    // Find the first quadratic non-residue z by brute-force search
    // Step 2
    z = 1
    while legendreSymbol(z, modulus: p) != -1 {
        z += 1
    }
    c = z.power(q, modulus: p)
    
    // Step 3
    r = n.power((q + 1) / 2, modulus: p)
    t = n.power(q, modulus: p)
    m = s
    while t != 1 {
        // Find the lowest i such that t^(2^i) = 1
        i = 0
        var tt: BigNumber = t
        while tt != 1 {
            tt = tt.power(2, modulus: p)
            i += 1
            if i == m { return nil }
        }
        
        // Update next value to iterate
        // Calculates 2^(m - i - 1)
        let exponentForB = BigNumber(2).power((m - i - 1), modulus: p - 1)
        b = c.power(exponentForB, modulus: p)
        c = b.power(2, modulus: p)
        r =  (r*b) % p
        t =  (t*c) % p
        m = i
    }
    
    if r.power(2, modulus: p) == n { return [r, p - r] }
    return nil
}

/// Calculate the square roots 𝑥² ≡ n (mod p).
public func squareRoots(of n: BigNumber, modulus p: BigNumber) -> [BigNumber]? {
    let n = n % p
    
    guard n != 0 else { return [0] }
    guard p != 2 else { return [n] }
    
    guard legendreSymbol(n, modulus: p) == 1 else { return nil }
    
    // Common case #1
    if p % 4 == 3 {
        let x = n.power((p + 1)/4, modulus: p)
        return [x, p-x]
    }
    
    // Common case #2
    if p % 8 == 5 {
        if n == n.power((p + 3)/4, modulus: p) {
            let x = n.power((p + 3)/8, modulus: p)
            return [x, p-x]
        }
        let s = n.power((p + 3)/8, modulus: p)
        
        guard let ts = tonelliShanks(p - 1, modulus: p) else { return nil }
        
        let x = (ts[0] * s) % p
        return [x, p-x]
    }
    
    // Shouldn't end up here very often.
    return tonelliShanks(n, modulus: p)
    
}

