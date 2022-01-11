//
//  Signature.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/27.
//

import Foundation

public struct Signature<T>: Equatable, CustomStringConvertible where T: EllipticCurve {
    let r: BigNumber
    let s: BigNumber
    
    init?(r: BigNumber, s: BigNumber) {
        guard r < T.P, s < T.N, r > 0 , s > 0 else {
            return nil
        }
        self.r = r
        var tmpS = s
        if s > T.N / 2 {
            tmpS = T.N - s
        }
        self.s = tmpS
    }
    
    init?(der: Data) {
        guard let (r, s) = DER.decode(data: der) else {
            return nil
        }
        self.init(r: r, s: s)
    }
    
    public var der: String {
        return DER.encode(r: r, s: s)
    }
}

public extension Signature {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.r == rhs.r && lhs.s == rhs.s
    }
    
    static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
    
}

public extension Signature {
    init?(hex: String) {
        guard hex.count == 128, case let rHex = String(hex.prefix(64)), case let sHex = String(hex.suffix(64)), sHex.count == 64, let r = BigNumber(hex: rHex), let s = BigNumber(hex: sHex) else {
            return nil
        }
        self.init(r: r, s: s)
    }
}

public extension Signature {
    var hex: String {
        return [r, s].map{ $0.hexStringLength64() }.joined()
    }
    
    var description: String {
        return hex
    }
    
    var data: Data {
        return Data(hex: hex)
    }
}
