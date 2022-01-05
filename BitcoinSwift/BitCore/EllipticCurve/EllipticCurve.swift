//
//  EllipticCurve.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import Foundation

public protocol EllipticCurve {
    
    typealias ECCPoint = Point<Self>
    
    static var P: BigNumber { get }
    static var N: BigNumber { get }
    static var a: BigNumber { get }
    static var b: BigNumber { get }
    static var G: ECCPoint { get }
}

extension EllipticCurve {
    static func modP(_ expression: () -> BigNumber) -> BigNumber {
        return mod(expression: expression, modulus: P)
    }
    
    static func modN(_ expression: () -> BigNumber) -> BigNumber {
        return mod(expression: expression, modulus: N)
    }
    
    static func divideP(_ molecule: BigNumber, denominator: BigNumber) -> BigNumber {
        return divide(molecule, by: denominator, mod: P)
    }
    
    static func divideN(_ molecule: BigNumber, denominator: BigNumber) -> BigNumber {
        return divide(molecule, by: denominator, mod: N)
    }
}



