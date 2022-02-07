//
//  Mrumur3.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import Foundation

public struct Murmur3 {
    public static func hash(_ message: Data, seed: UInt32 = 0) -> UInt32 {
        let c1: UInt32 = 0xcc9e2d51
        let c2: UInt32 = 0x1b873593
        let length = message.count
        var h1 = seed
        let roundEnd = length & 0xfffffffc
        for i in stride(from: 0, to: roundEnd, by: 4) {
            var k1 = UInt32(message[i]) | UInt32(message[i + 1]) << 8 | UInt32(message[i + 2]) << 16 | UInt32(message[i + 3]) << 24
            k1 &*= c1
            k1 = rotateLeft32(k1, 15)
            k1 &*= c2
            
            h1 ^= k1
            h1 = rotateLeft32(h1, 13)
            h1 = h1 &* 5 &+ 0xe6546b64
        }
        var k1: UInt32 = 0
        let val = length & 0x03
        switch val {
        case 3:
            k1 = UInt32(message[roundEnd + 2]) << 16
            fallthrough
        case 2:
            k1 |= (UInt32(message[roundEnd + 1]) << 8)
            fallthrough
        case 1:
            k1 |= UInt32(message[roundEnd])
            k1 &*= c1
            k1 = rotateLeft32(k1, 15)
            k1 &*= c2
            h1 ^= k1
        default:
            break
        }
        h1 ^= UInt32(truncatingIfNeeded: length)
        h1 = fmix(h1)
        return h1
    }
}

private extension Murmur3 {
    
    static func rotateLeft32(_ x: UInt32, _ r: UInt32) -> UInt32 {
        return (x << r) | (x >> (32 - r))
    }
    
    static func fmix(_ h: UInt32) -> UInt32 {
        var h1 = h
        h1 ^= (h1 >> 16)
        h1 &*= 0x85ebca6b
        h1 ^= (h1 >> 13)
        h1 &*= 0xc2b2ae35
        h1 ^= (h1 >> 16)
        return h1
    }
}
