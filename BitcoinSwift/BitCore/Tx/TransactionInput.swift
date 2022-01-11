//
//  TransactionInput.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct TransactionInput {
    
    let prevTx: Data
    let prevIndex: UInt32
    let scriptSig: Script
    let sequence: UInt32
    
    public init(prevTx: Data, prevIndex: UInt32, scriptSig: Script? = nil, sequence: UInt32 = 0xFFFFFFFF) {
        self.prevTx = prevTx
        self.prevIndex = prevIndex
        self.scriptSig = scriptSig == nil ? Script() : scriptSig!
        self.sequence = sequence
    }
    
    public func serialize() -> Data {
        var result = Data(prevTx.reversed())
        result += prevIndex.littleEndian.data
        result += scriptSig.serialize()
        result += sequence.littleEndian.data
        return result
    }
    
}

public extension TransactionInput {
    
    static func parse(_ stream: ByteStream) -> Self {
        let prevTx = Data(stream.read(Data.self, count: 32).reversed())
        let prevIndex = stream.read(UInt32.self).littleEndian
        let scriptLength = stream.read(VarInt.self)
        let signatureScript = stream.read(Data.self, count: Int(scriptLength.underlyingValue))
        let script = Script(signatureScript)!
        let sequence = stream.read(UInt32.self)
        return TransactionInput(prevTx: prevTx, prevIndex: prevIndex, scriptSig: script, sequence: sequence)
    }
}

extension TransactionInput: CustomStringConvertible {
    public var description: String {
        return "\(prevTx.hex):\(prevIndex)"
    }
}
