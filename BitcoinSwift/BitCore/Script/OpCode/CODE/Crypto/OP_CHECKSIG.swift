//
//  OP_CHECKSIG.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckSig: OpCodeType {
    public var value: UInt8 { return 0xac }
    public var name: String { return "OP_CHECKSIG" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        guard let tx = context.transaction, let utxo = context.utxoToVerify else {
            throw OpCodeExcutionError.error("The transaction or the utxo to verify is not set.")
        }
        let secPubKey = context.remove(at: -1)
        let derData = context.remove(at: -1)
        let verify = try ECDSA<Secp256k1>.verify(derData, tx: tx, inputIndex: Int(context.inputIndex), utxo: utxo, pubKeyData: secPubKey)
        context.push(verify)
    }
}
