//
//  OP_CHECKMULTISIG.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckMultiSig: OpCodeType {
    public var value: UInt8 { return 0xae }
    public var name: String { return "OP_CHECKMULTISIG" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let pubkeyNum = Int(try context.number(at: -1))
        guard pubkeyNum >= 0 && pubkeyNum <= BTC_MAX_KEYS_FOR_CHECKMULTISIG else {
            throw OpCodeExcutionError.error("Invalid number of keys for \(name): \(pubkeyNum).")
        }
        try context.incrementOpCount(by: pubkeyNum)
        try context.assertStackHeightGreaterThanOrEqual(pubkeyNum + 1)
        var pubKeys = [Data]()
        for _ in 0..<pubkeyNum {
            pubKeys.append(context.remove(at: -1))
        }
        
        try context.assertStackHeightGreaterThanOrEqual(1)
        let sigNum = Int(try context.number(at: -1))
        guard sigNum >= 0 && sigNum <= pubkeyNum else {
            throw OpCodeExcutionError.error("Invalid number of signatures for \(name): \(sigNum).")
        }
        
        try context.assertStackHeightGreaterThanOrEqual(sigNum + 1)
        var signatures = [Data]()
        for _ in 0..<sigNum {
            // FIXME: - 是否需要去掉最后一位hashtype 位
            signatures.append(context.remove(at: -1))
        }
        
        try context.assertStackHeightGreaterThanOrEqual(1)
        context.remove(at: -1)
        
        var success = true
        var sigError: Error?
        guard let tx = context.transaction, let utxo = context.utxoToVerify else {
            throw OpCodeExcutionError.error("The transaction or the utxo to verify is not set.")
        }
        
        while success && !signatures.isEmpty {
            let secPubKey = pubKeys.removeFirst()
            let derData = signatures[0]
            do {
                /**
                let point = try Point<Secp256k1>(data: secPubKey)
                guard let sig = Signature<Secp256k1>(der: derSignature) else {
                    throw OpCodeExcutionError.error(" Signature cannot create ")
                }
                guard let hashType = BTCSigHashType(rawValue:derData.last!) else {
                    throw OpCodeExcutionError.error("SigHashType error")
                }
                let helper = SignatureHash(hashType: hashType)
                let signatureHash = helper.createSignatureHash(of: tx, for: utxo, inputIndex: Int(context.inputIndex))
                let verify = point.verify(Message(raw: signatureHash), signature: sig)
                 */
                let verify = try ECDSA<Secp256k1>.verify(derData, tx: tx, inputIndex: Int(context.inputIndex), utxo: utxo, pubKeyData: secPubKey)
                if verify {
                    signatures.removeFirst()
                }
            } catch let err {
                if sigError == nil {
                    sigError = err
                }
            }
            
            if pubKeys.count < signatures.count {
                success = false
            }
        }
        context.push(success)
    }
}
