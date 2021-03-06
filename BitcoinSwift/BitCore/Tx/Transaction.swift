//
//  Transaction.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct Transaction {
    
    public var id: String {
        return hash.hex
    }
    
    public var hash: Data {
        let hash256 = Crypto.hash256(self.serialize())
        return Data(hash256.reversed())
    }
    
    public var isCoinbase: Bool {
        return inputs.count == 1 && inputs[0].prevTx == Data(repeating: 0, count: 32) && inputs[0].prevIndex == 0xFFFF_FFFF
    }
    
    public let version: UInt32
    public let inputs: [TransactionInput]
    public let outputs: [TransactionOutput]
    public let lockTime: UInt32
    
    public init(version: UInt32, inputs: [TransactionInput], outputs: [TransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
    }
    
    //FIXME: - segwit
    
    public func serialize() -> Data {
        var result = version.littleEndian.data
        result += VarInt(inputs.count).serialize()
        result += inputs.flatMap{ $0.serialize() }
        result += VarInt(outputs.count).serialize()
        result += outputs.flatMap{ $0.serialize() }
        result += lockTime.littleEndian.data
        
        return result
    }
    
    public func signHash(_ index: Int, redeemScript: Script? = nil) -> Data {
        var result = version.littleEndian.data
        result += VarInt(inputs.count).serialize()
        for (i, input) in inputs.enumerated() {
            var scriptSig: Script? = nil
            if i == index {
                if redeemScript != nil {
                    scriptSig = redeemScript!
                } else {
                    // FIXME: - the previous tx's ScriptPubkey is the ScriptSig, need url get
//                    scriptSig = input.
                }
            }
            result += TransactionInput(prevTx: input.prevTx, prevIndex: input.prevIndex, scriptSig: scriptSig, sequence: input.sequence).serialize()
        }
        result += VarInt(outputs.count).serialize()
        result += outputs.flatMap{ $0.serialize() }
        result += lockTime.littleEndian.data
        result += BTCSigHashType.ALL.uint32.littleEndian.data
        let hash256 = Crypto.hash256(result)
        return hash256
    }
    
}

public extension Transaction {
    //FIXME: - segwit
    static func parse(_ stream: ByteStream) -> Self {
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
