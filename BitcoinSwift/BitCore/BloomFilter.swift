//
//  BloomFilter.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import Foundation

public struct BloomFilter {
    public let size: UInt32
    public let tweak: UInt32
    public let funcs: UInt32
    
    private var bitField: [UInt8]
    
    let MAX_FILTER_SIZE: UInt32 = 36_000
    let MAX_HASH_FUNCS: UInt32 = 50
    let BIP37_CONSTANT: UInt32 = 0xFBA4C795
    
    public var bytes: Data {
        return bitFieldToBytes(bitField)!
    }
    
    public init(size: UInt32, funcs: UInt32, tweak: UInt32) {
        self.size = size
        self.funcs = funcs
        self.tweak = tweak
        self.bitField = [UInt8](repeating: 0, count: Int(size) * 8)
    }
    
    public init(elements: Int, falsePositiveRate: Double, randomNonce tweak: UInt32) {
        self.size = max(1, min(UInt32(-1.0 / pow(log(2), 2) * Double(elements) * log(falsePositiveRate)), MAX_FILTER_SIZE * 8) / 8)
        self.funcs = max(1, min(UInt32(Double(size * UInt32(8)) / Double(elements) * log(2)), MAX_HASH_FUNCS))
        self.tweak = tweak
        self.bitField = [UInt8](repeating: 0, count: Int(size) * 8)
    }
    
    public mutating func add(_ data: Data) {
        for i in 0..<funcs {
            let seed = i &* BIP37_CONSTANT &+ tweak
            let h = Murmur3.hash(data, seed: seed)
            let bit = Int(h % (size * 8))
            self.bitField[bit] = 1
        }
    }
    
    public func filterLoad(_ flag: UInt8 = 1) -> GenericMessage {
        var payload = VarInt(UInt64(size)).serialize()
        payload += bytes
        payload += funcs.littleEndian.data
        payload += tweak.littleEndian.data
        payload += flag.littleEndian.data
        return GenericMessage(command: "filterload", payload: payload)
    }
    
}

extension BloomFilter {
    func bitFieldToBytes(_ bitField:[UInt8]) -> Data? {
        if bitField.count % 8 != 0 {
            return nil
        }
        let count = bitField.count / 8
        var result = [UInt8](repeating: 0, count: count)
        for (i, bit) in bitField.enumerated() {
            let (byteIndex, bitIndex) = i.quotientAndRemainder(dividingBy: 8)
            if bit == 1 {
                result[byteIndex] |= 1 << bitIndex
            }
        }
        return Data(result)
    }
}
