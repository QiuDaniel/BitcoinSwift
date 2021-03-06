//
//  ByteStream.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import Foundation

public final class ByteStream {
    let data: Data
    private var offset = 0
    
    var availableByteCount: Int {
        return data.count - offset
    }
    
    init(_ data: Data) {
        self.data = data
    }
    
    func read<T>(_ type: T.Type) -> T {
        let size = MemoryLayout<T>.size
        let value = data[offset..<(offset + size)].to(type)
        offset += size
        return value
    }
}

extension ByteStream {
    
    func read(_ type: VarInt.Type) -> VarInt {
        let len = data[offset..<(offset + 1)].to(UInt8.self)
        let length: UInt64
        switch len {
        case 0...252:
            length = UInt64(len)
            offset += 1
        case 0xfd:
            offset += 1
            length = UInt64(data[offset..<(offset + 2)].to(UInt16.self))
            offset += 2
        case 0xfe:
            offset += 1
            length = UInt64(data[offset..<(offset + 4)].to(UInt32.self))
            offset += 4
        case 0xff:
            offset += 1
            length = data[offset..<(offset + 8)].to(UInt64.self)
            offset += 8
        default:
            offset += 1
            length = data[offset..<(offset + 8)].to(UInt64.self)
            offset += 8
        }
        return VarInt(length)
    }
    
    func read(_ type: VarString.Type) -> VarString {
        let length = read(VarInt.self).underlyingValue
        let size = Int(length)
        let value = data[offset..<(offset + size)].to(String.self)
        offset += size
        return VarString(value)
    }
    
    func read(_ type: Data.Type, count: Int) -> Data {
        let value = data[offset..<(offset + count)]
        offset += count
        return Data(value)
    }
}
