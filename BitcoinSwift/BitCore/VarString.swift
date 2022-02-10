//
//  VarString.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/9.
//
// copy from https://github.com/yenom/BitcoinKit/blob/master/Sources/BitcoinKit/Messages/VarString.swift

import Foundation

/// Variable length string can be stored using a variable length integer followed by the string itself.

public struct VarString: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    public let length: VarInt
    public let value: String
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(_ value: String) {
        self.value = value
        length = VarInt(value.data(using: .ascii)!.count)
    }
    
    public func serialize() -> Data {
        var result = length.serialize()
        result += value.toData()
        return result
    }
    
}

extension VarString: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}
