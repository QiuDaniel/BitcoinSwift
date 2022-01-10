//
//  Point+Static.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/6.
//

import Foundation
import BigInt

extension Point {
    
    enum PointError: Error {
        case incorrectByteCountOfPublicKey(expectedByteCount: Int, actual: Int)
        case failedToSerializeBytes
    }
    
    static func parseFromUncompressedPublicKey(bytes: Data) throws -> Self {
        guard bytes.count == 65 else {
            throw PointError.incorrectByteCountOfPublicKey(expectedByteCount: 65, actual: bytes.count)
        }
        precondition(bytes[0] == 0x04)
        let x = BigNumber(BigUInt(bytes.subdata(in: 1..<33)))
        let y = BigNumber(BigUInt(bytes.subdata(in: 33..<65)))
        return Self(x: x, y: y)
    }
    
    static func parseFromCompressedPublicKey(bytes: Data) throws -> Self {
        guard bytes.count == 33 else {
            throw PointError.incorrectByteCountOfPublicKey(expectedByteCount: 33, actual: bytes.count)
        }
        let isEven = bytes[0] == 0x02
        return parseFrom(x: .init(bytes.suffix(32)), isEven: isEven)
    }
    
    static func parseFrom(x: BigNumber, isEven: Bool) -> Self {
        let P = Curve.P
        let a = Curve.a
        let b = Curve.b
        
        //  y² = x³ + ax + b
        let x3 = x.power(3, modulus: P)
        let y2 = modP { x3 + a * x + b }
        
        guard let squareRootsOfY = squareRoots(of: y2, modulus: P) else {
            fatalError("Expected to always be able to calc square roots of Y")
        }
        
        guard let firstY = squareRootsOfY.first else {
            fatalError("Expected to always be able to get one root of Y")
        }
        let y: BigNumber
        if isEven {
            y = (firstY.modulus(2) == 0 ? firstY : firstY.negated()).modulus(P)
        } else {
            y = (firstY.modulus(2) == 1 ? firstY : firstY.negated()).modulus(P)
        }
        return .init(x: x, y: y)
    }
}
