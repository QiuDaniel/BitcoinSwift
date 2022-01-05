//
//  Block.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/4.
//

import Foundation
import BigInt

public struct Block {
    
    public let version: Int32
    public let prevBlock: Data
    public let merkleRoot: Data
    public let timestamp: UInt32
    public let bits: UInt32
    public let nonce: UInt32
    
    private static let TWO_WEEKS = 60 * 60 * 24 * 14
    
    
    public var blockHash: Data {
        let hash256 = Crypto.hash256(serialize())
        return Data(hash256.reversed())
    }
    
    public var blockId: String {
        return blockHash.hex
    }
    
    public var isBIP9: Bool {
        return version >> 29 == 0b001
    }
    
    public var isBIP91: Bool {
        return version >> 4 & 1 == 1
    }
    
    public var isBIP141: Bool {
        return version >> 1 & 1 == 1
    }
    
    public var target: BigUInt {
        return Self.target(fromBits: bits)
    }
    
    public var difficulty: BigUInt {
        let lowest = 0xffff * BigUInt(256).power(Int(0x1d) - 3)
        return lowest / self.target
    }
    
    static func parse(_ data: Data) -> Block {
        let stream = ByteStream(data)
        let version = stream.read(Int32.self).littleEndian
        let prevBlock = Data(stream.read(Data.self, count: 32).reversed())
        let merkleRoot = Data(stream.read(Data.self, count: 32).reversed())
        let timestamp = stream.read(UInt32.self).littleEndian
        let bits = stream.read(UInt32.self)
        let nonce = stream.read(UInt32.self)
        return Block(version: version, prevBlock: prevBlock, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce)
    }
    
    func serialize() -> Data {
        var result: Data = .empty
        result += version.littleEndian.data
        result += Data(prevBlock.reversed())
        result += Data(merkleRoot.reversed())
        result += timestamp.littleEndian.data
        result += bits.data
        result += nonce.data
        return result
    }
    
    func checkPoW() -> Bool {
        let h256 = Crypto.hash256(serialize())
        let proof = BigNumber(Data(h256.reversed()))
        return proof < self.target
    }
    
    // TODO: - validateMerkleRoot
//    func validateMerkleRoot() -> Bool {
//
//    }
}

extension Block {
    
    private static func target(fromBits bits: UInt32) -> BigUInt {
        var bitsBytes = bits.bytes
        let exponent = bitsBytes.removeLast()
        let coefficient = BigNumber(bitsBytes.reversed())
        let target = coefficient * BigNumber(256).power(Int(exponent) - 3)
        return BigUInt(target)
    }
    
    static func bits(fromTarget target: BigUInt) -> UInt32 {
        let rawBytes = target.trimmedData().bytes
        var exponent = rawBytes.count
        var coefficient = rawBytes[0..<3]
        if rawBytes[0] > 0x7f {
            exponent = rawBytes.count + 1
            coefficient = [0x00] + rawBytes[0..<2]
        }
        let newBits = coefficient.reversed() + [UInt8(exponent)]
        return Data(newBits).to(UInt32.self)
    }
    
    static func calculateNewBits(prevBits: UInt32, timeDifferential: UInt32) -> UInt32 {
        var diff = timeDifferential
        if diff > TWO_WEEKS * 4 {
            diff = UInt32(TWO_WEEKS * 4)
        }
        if diff < TWO_WEEKS / 4 {
            diff = UInt32(TWO_WEEKS / 4)
        }
        let newTarget = BigUInt(target(fromBits: prevBits)) * BigUInt(diff) / BigUInt(TWO_WEEKS)
        return bits(fromTarget: newTarget)
    }

    
}
