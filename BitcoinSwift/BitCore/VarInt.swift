//
//  VarInt.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct VarInt {
    
    public typealias IntegerLiteralType = UInt64
    public let underlyingValue: UInt64
    let length: UInt8
    let data: Data
    
    /*
     0xfc : 252
     0xfd : 253
     0xfe : 254
     0xff : 255
     
     0~252 : 1-byte(0x00 ~ 0xfc)
     253 ~ 65535: 3-byte(0xfd00fd ~ 0xfdffff)
     65536 ~ 4294967295 : 5-byte(0xfe010000 ~ 0xfeffffffff)
     4294967296 ~ 1.84467441e19 : 9-byte(0xff0000000100000000 ~ 0xfeffffffffffffffff)
    */
    
    init(_ value: UInt64) {
        underlyingValue = value
        
        switch value {
        case 0...252:
            length = 1
            data = .empty + UInt8(value).littleEndian
        case 253...0xffff:
            length = 2
            data = .empty + UInt8(0xfd).littleEndian + UInt16(value).littleEndian
        case 0x10000...0xffffffff:
            length = 4
            data = .empty + UInt8(0xfe).littleEndian + UInt32(value).littleEndian
        case 0x100000000...0xffffffffffffffff:
            length = 8
            data = .empty + UInt8(0xff).littleEndian + UInt64(value).littleEndian
        default:
            fatalError("This switch statement should be exhaustive without default clause")
        }
    }
    
    init(_ value: Int) {
        self.init(UInt64(value))
    }
    
    func serialize() -> Data {
        return data
    }
    
    static func parse(_ data: Data) -> VarInt {
        return data.to(self)
    }
}

extension VarInt: CustomStringConvertible {
    public var description: String {
        return "\(underlyingValue)"
    }
}
