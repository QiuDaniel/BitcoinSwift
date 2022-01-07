//
//  SignatureHashHelper.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/6.
//

import Foundation

public struct SignatureHashHelper {
    
    public func createSignatureHash(of tx: Transaction, for utxoOutput: TransactionOutput, inputIndex: Int) -> Data {
        // If inputIndex is out of bounds, BitcoinABC is returning a 256-bit little-endian 0x01 instead of failing with error.
        guard inputIndex < tx.inputs.count else {
            //  tx.inputs[inputIndex] out of range
            return one
        }

        // Check for invalid use of SIGHASH_SINGLE
        guard !(hashType.isSingle && inputIndex < tx.outputs.count) else {
            //  tx.outputs[inputIndex] out of range
            return one
        }

        // Modified Raw Transaction to be serialized
        let rawTransaction = Transaction(version: tx.version,
                              inputs: createInputs(of: tx, for: utxoOutput, inputIndex: inputIndex),
                              outputs: createOutputs(of: tx, inputIndex: inputIndex),
                              lockTime: tx.lockTime)
        var data: Data = rawTransaction.serialized()

        data += hashType.uint32
        let hash = Crypto.sha256sha256(data)
        return hash
    }
}
