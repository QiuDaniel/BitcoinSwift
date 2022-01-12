//
//  TransactionOut.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct TransactionOutput {
    
    public let amount: UInt64
    public let scriptPubkey: Script
    
    private var scriptLength: VarInt {
        return VarInt(scriptPubkey.data.count)
    }
    
    public init(amount: UInt64, scriptPubkey: Script) {
        self.amount = amount
        self.scriptPubkey = scriptPubkey
    }
    
    public init() {
        self.init(amount: 0, scriptPubkey: Script())
    }
    
    public func serialize() -> Data {
        var result = Data.empty
        result += amount.littleEndian.data
        result += scriptPubkey.serialize()
        return result
    }
}

public extension TransactionOutput {
    
    static func parse(_ stream: ByteStream) -> Self {
        let amount = stream.read(UInt64.self).littleEndian
        let scriptLength = stream.read(VarInt.self)
        let scriptData = stream.read(Data.self, count: Int(scriptLength.underlyingValue))
        let script = Script(scriptData)!
        return TransactionOutput(amount: amount, scriptPubkey: script)
    }
}

extension TransactionOutput: CustomStringConvertible {
    public var description: String {
        return "\(amount):\(scriptPubkey)"
    }
}
