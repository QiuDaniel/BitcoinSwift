//
//  EllipticCurvePoint.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import Foundation

public protocol EllipticCurvePoint: Equatable, CustomStringConvertible {
    
    associatedtype Curve: EllipticCurve
    
    var x: BigNumber { get }
    var y: BigNumber { get }
    
    init(x: BigNumber, y: BigNumber)
    
    static func add(_ p1: Self?, _ p2: Self?) -> Self?
    
    static func *(point: Self, coefficient: BigNumber) -> Self
}

public extension EllipticCurvePoint {
    
    static func modP(_ expression: () -> BigNumber) -> BigNumber {
        return Curve.modP(expression)
    }
    
    static func modN(_ expression: () -> BigNumber) -> BigNumber {
        return Curve.modN(expression)
    }
    
    static func divideP(_ molecule: BigNumber, denominator: BigNumber) -> BigNumber {
        return Curve.divideP(molecule, denominator: denominator)
    }
    
    static func divideN(_ molecule: BigNumber, denominator: BigNumber) -> BigNumber {
        return Curve.divideN(molecule, denominator: denominator)
    }
    
    var isOnCurve: Bool {
        let a = Curve.a
        let b = Curve.b
        let x = self.x
        let y = self.y

        let y² = Self.modP { y * y }
        let x³ = Self.modP { x * x * x }
        let ax = Self.modP { a * x }

        return Self.modP { y² - x³ - ax } == b
    }
}

public extension EllipticCurvePoint {
    
    var description: String {
        return "(x: \(x.hexString()), y: \(y.hexString())"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
}
