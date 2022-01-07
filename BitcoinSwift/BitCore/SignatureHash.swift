//
//  SignatureHashHelper.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/6.
//

import Foundation

public struct SignatureHash {
    
    public let zero: Data = Data(repeating: 0, count: 32)
    public let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

    public let hashType: SigHashType
    
    public init(hashType: SigHashType) {
        self.hashType = hashType
    }
    
    /// Create the transaction input to be signed
    public func createSigningInput(of txin: TransactionInput, from utxoOutput: TransactionOutput) -> TransactionInput {
        let subScript = Script(utxoOutput.scriptPubkey.data)!
        try! subScript.deleteOccurrences(of: .OP_CODESEPARATOR)
        return TransactionInput(prevTx: txin.prevTx, prevIndex: txin.prevIndex, scriptSig: subScript, sequence: txin.sequence)
    }

    /// Create a blank transaction input
    public func createBlankInput(of txin: TransactionInput) -> TransactionInput {
        let sequence: UInt32
        if hashType.isNone || hashType.isSingle {
            sequence = 0
        } else {
            sequence = txin.sequence
        }
        return TransactionInput(prevTx: txin.prevTx, prevIndex: txin.prevIndex, scriptSig: Script(), sequence: sequence)
    }
    
    /// Create the transaction inputs
    public func createInputs(of tx: Transaction, for utxoOutput: TransactionOutput, inputIndex: Int) -> [TransactionInput] {
        // If SIGHASH_ANYONECANPAY flag is set, only the input being signed is serialized
        if hashType.isAnyoneCanPay {
            return [createSigningInput(of: tx.inputs[inputIndex], from: utxoOutput)]
        }

        // Otherwise, all inputs are serialized
        var inputs: [TransactionInput] = []
        for i in 0..<tx.inputs.count {
            let txin = tx.inputs[i]
            if i == inputIndex {
                inputs.append(createSigningInput(of: txin, from: utxoOutput))
            } else {
                inputs.append(createBlankInput(of: txin))
            }
        }
        return inputs
    }

    /// Create the transaction outputs
    public func createOutputs(of tx: Transaction, inputIndex: Int) -> [TransactionOutput] {
        if hashType.isNone {
            // Wildcard payee - we can pay anywhere.
            return []
        } else if hashType.isSingle {
            // Single mode assumes we sign an output at the same index as an input.
            // All outputs before the one we need are blanked out. All outputs after are simply removed.
            // Only lock-in the txout payee at same index as txin.
            // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
            let myOutput = tx.outputs[inputIndex]
            return Array(repeating: TransactionOutput(), count: inputIndex) + [myOutput]
        } else {
            return tx.outputs
        }
    }
    
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
        var data: Data = rawTransaction.serialize()

        data += hashType.uint32
        let hash = Crypto.hash256(data)
        return hash
    }
}
