//
//  ECDSA.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/7.
//

import Foundation
import AppKit

public enum SigningError: Error {
    case error(String)
}

public struct ECDSA<CurveType: EllipticCurve> {
    public typealias Curve = CurveType
}

public extension ECDSA {
    
    static func verify(_ sigData: Data, tx: Transaction, inputIndex: Int, utxo: TransactionOutput, pubKeyData: Data) throws -> Bool {
        let point = try Point<Curve>(data: pubKeyData)
        guard let hashType = BTCSigHashType(rawValue:sigData.last!) else {
            throw SigningError.error("SigHashType error")
        }
        let helper = SignatureHash(hashType: hashType)
        guard let sig = Signature<Curve>(der: sigData.dropLast()) else {
            throw SigningError.error(" Signature cannot create ")
        }
        let signatureHash = helper.createSignatureHash(of: tx, for: utxo, inputIndex: inputIndex)
        return verify(Message(raw: signatureHash), signature: sig, point: point)
    }
    
    static func verify(_ message: Message, signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {
        return publicKey.point.verify(message, signature: signature)
    }
    
    static func verify(_ message: Message, signature: Signature<Curve>, point: Point<Curve>) -> Bool {
        return point.verify(message, signature: signature)
    }
}
