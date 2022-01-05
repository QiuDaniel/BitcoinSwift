//
//  Base58.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/22.
//

import Foundation
import BigInt

private struct _Base58 {
    static let baseAlphabets = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    static let zeroAlphabet: Character = "1"
    static let base: Int = 58
    
    static func encode(_ bytes: Data) -> String {
        var count = 0
        let radix = BigUInt(base)
        for b in bytes {
            guard b == 0 else {
                break
            }
            count += 1
        }
        var num = BigUInt(bytes)
        var str = ""
        var prefix = ""
        while count > 0 {
            prefix += String(zeroAlphabet)
            count -= 1
        }
        while num > 0 {
            let (quotient, modulus) = num.quotientAndRemainder(dividingBy: radix)
            str = baseAlphabets[Int(modulus)] + str
            num = quotient
        }
        
        return prefix + str
    }
    
    static func decode(_ hex: String, uppercased: Bool = true) -> Data? {
        let alphabet = baseAlphabets.data
        let radix = BigUInt(base)
        var num = BigUInt(0)
        var temp = BigUInt(1)
        let byteString = [UInt8](hex.utf8)
        var zerosCount = 0
        for c in hex {
            if c != zeroAlphabet { break }
            zerosCount += 1
        }
        for c in byteString.reversed() {
            guard let i = alphabet.firstIndex(of: c) else {
                return nil
            }
            num += temp * BigUInt(i)
            temp *= radix
        }
        return Data(repeating: 0, count: zerosCount) + num.serialize()
    }
}

public struct Base58 {
    public static func encode(_ bytes: Data) -> String {
        return _Base58.encode(bytes)
    }
    
    public static func decode(_ hex: String, uppercased: Bool = true) -> Data? {
        return _Base58.decode(hex, uppercased: uppercased)
    }
    
}

