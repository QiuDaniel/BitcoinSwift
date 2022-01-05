//
//  Secp256k1.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import Foundation

/// The curve E: `y² = x³ + ax + b` over Fp
public struct Secp256k1: EllipticCurve {
    
    /// `2^256 −2^32 −2^9 −2^8 −2^7 −2^6 −2^4 − 1` <=> `2^256 - 2^32 - 977`
    public static let P = BigNumber(hex: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!
    
    public static let a = BigNumber(0)
    public static let b = BigNumber(7)
    
    public static let N = BigNumber(hex: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
    
    public static let G = ECCPoint(x: BigNumber(hex:"0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")!, y: BigNumber(hex: "0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8")!)
    
}
