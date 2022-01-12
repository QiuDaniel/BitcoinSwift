//
//  Point.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import Foundation

public struct Point<CurveType: EllipticCurve>: EllipticCurvePoint {
    public typealias Curve = CurveType
    
    public let x: BigNumber
    public let y: BigNumber
    
    public init(x: BigNumber, y: BigNumber) {
        self.x = x
        self.y = y
    }
    
    public init(data: Data) throws {
        if data.count == 33 {
            self = try Self.parseFromCompressedPublicKey(bytes: data)
        } else if data.count == 65 {
            self = try Self.parseFromUncompressedPublicKey(bytes: data)
        } else {
            throw PointError.failedToSerializeBytes
        }
    }
    
    public init(hex: String) throws {
        try self.init(data: Data(hex: hex))
    }
    
    func verify(_ message: Message, signature: Signature<Curve>) -> Bool {
        guard self.isOnCurve else {
            return false
        }
        let z: BinaryConvertible = message
        let r = signature.r
        let s = signature.s
        let sInverse = Curve.divideN(1, denominator: s)
        let u = Curve.modN { z * sInverse }
        let v = Curve.modN { r * sInverse }
        guard let point = Self.add(Curve.G * u, self * v) else {
            return false
        }
        let verification = Curve.modN { point.x }
        return verification == r
    }
}

//public func * <C>(coefficient: BigNumber, point: Point<C>) -> Point<C> {
//    point * coefficient
//}

public extension Point {
    
    /// 有限域上的点加法
    /// - Parameters:
    ///   - p1: point
    ///   - p2: point
    /// - Returns: point
    static func add(_ p1: Point?, _ p2: Point?) -> Point? {
        guard let p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }
        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }
        if p1 == p2 {
            if p1.y == 0 * p2.y {
                return nil
            }
            return addSelf(p1)
        } else {
            return addPoint(p1, to: p2)
        }
    }
    
    
    /// 标量乘法
    /// - Parameters:
    ///   - point: Point
    ///   - coefficient: coefficient
    /// - Returns: coefficient * Point
    static func *(point: Self, coefficient: BigNumber) -> Point {
        var current: Self? = point
        var result: Self!
        for i in 0..<coefficient.magnitude.bitWidth {
            if coefficient.magnitude[bitAt: i] {
                result = add(result, current)
            }
            current = add(current, current)
        }
        return result
    }
    
}

private extension Point {
    
    static func addPoint(_ p1: Self, to p2: Self) -> Self {
        precondition(p1 != p2)
        let λ = divideP(p2.y - p1.y, denominator: p2.x - p1.x)
        let x3 = modP { λ * λ - p1.x - p2.x }
        let y3 = modP { λ * (p1.x - x3) - p1.y }
        return Self(x: x3, y: y3)
    }
    
    static func addSelf(_ point: Self) -> Self {
        let λ = divideP(3 * (point.x * point.x) + Curve.a, denominator: 2 * point.y)
        let x3 = modP{ λ * λ - 2 * point.x }
        let y3 = modP{ λ * (point.x - x3) - point.y }
        return Self(x: x3, y: y3)
    }
}
