//
//  MerkleBlock.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import Foundation
import BigInt

public struct MerkleBlock {
    public let version: Int32
    public let prevBlock: Data
    public let merkleRoot: Data
    public let timestamp: UInt32
    public let bits: UInt32
    public let nonce: UInt32
    public let total: UInt32
    public let hashes: [Data]
    public let flags: [UInt8]

    
    public static func parse(_ data: Data) -> MerkleBlock {
        let stream = ByteStream(data)
        let version = stream.read(Int32.self).littleEndian
        let prevBlock = Data(stream.read(Data.self, count: 32).reversed())
        let merkleRoot = Data(stream.read(Data.self, count: 32).reversed())
        let timestamp = stream.read(UInt32.self).littleEndian
        let bits = stream.read(UInt32.self)
        let nonce = stream.read(UInt32.self)
        let total = stream.read(UInt32.self).littleEndian
        let hashesNum = stream.read(VarInt.self)
        var hashes = [Data]()
        for _ in 0..<hashesNum.underlyingValue {
            hashes.append(Data(stream.read(Data.self, count: 32).reversed()))
        }
        let flagLength = stream.read(VarInt.self)
        var flags = [UInt8]()
        for _ in 0..<flagLength.underlyingValue {
            flags.append(stream.read(UInt8.self))
        }
        return MerkleBlock(version: version, prevBlock: prevBlock, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce, total: total, hashes: hashes, flags: flags)
    }
    
    public func isValid() -> Bool {
        let hashes = self.hashes.map { Data($0.reversed()) }
        let flagBits = bytes2bitField(flags)
        let tree = MerkleTree(BigUInt(total))
        do {
            try tree.populateTree(flagBits: flagBits, hashes: hashes)
        } catch {
            return false
        }
        guard let root = tree.root.hash, root != .empty else {
            return false
        }
        return Data(root.reversed()) == merkleRoot
    }
}
