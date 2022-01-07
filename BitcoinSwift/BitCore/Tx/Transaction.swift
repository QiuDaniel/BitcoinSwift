//
//  Transaction.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct Transaction {
    
    var id: String {
        return hash.hex
    }
    
    var hash: Data {
        let hash256 = Crypto.hash256(self.serialize())
        return Data(hash256.reversed())
    }
    
    let version: UInt32
    let inputs: [TransactionInput]
    let outputs: [TransactionOutput]
    let lockTime: UInt32
    
    init(version: UInt32, inputs: [TransactionInput], outputs: [TransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
    }
    
    //FIXME: - segwit
    
    func serialize() -> Data {
        var result = version.littleEndian.data
        result += VarInt(inputs.count).serialize()
        result += inputs.flatMap{ $0.serialize() }
        result += VarInt(outputs.count).serialize()
        result += outputs.flatMap{ $0.serialize() }
        result += lockTime.littleEndian.data
        
        return result
    }
    
    
    
}

public extension Transaction {
    //FIXME: - segwit
    static func parse(_ data: Data) -> Self {
        let stream = ByteStream(data)
        let version = stream.read(UInt32.self).littleEndian
        let txInCount = stream.read(VarInt.self)
        var inputs = [TransactionInput]()
        for _ in 0..<Int(txInCount.underlyingValue) {
            inputs.append(TransactionInput.parse(stream))
        }
        let txOutCount = stream.read(VarInt.self)
        var outputs = [TransactionOutput]()
        for _ in 0..<Int(txOutCount.underlyingValue) {
            outputs.append(TransactionOutput.parse(stream))
        }
        let lockTime = stream.read(UInt32.self).littleEndian
        return .init(version: version, inputs: inputs, outputs: outputs, lockTime: lockTime)
    }
}

extension Transaction: CustomStringConvertible {
    public var description: String {
        let txIns = inputs.reduce("") { $0 + $1.description + "\n" }
        let txOuts = outputs.reduce("") { $0 + $1.description + "\n" }
        return "tx:\(id)\nversion:\(version)\ntx_ins:\n\(txIns)tx_outs:\n\(txOuts)locktime:\(lockTime)"
    }
}
