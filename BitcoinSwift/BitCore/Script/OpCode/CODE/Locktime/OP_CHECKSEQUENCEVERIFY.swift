//
//  OP_CHECKSEQUENCEVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckSequenceVerify: OpCodeType {
    public var value: UInt8 { return 0xb2 }
    public var name: String { return "OP_CHECKSEQUENCEVERIFY" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)

        // nLockTime should be Int5
        // reference: https://github.com/Bitcoin-ABC/bitcoin-abc/blob/73c5e7532e19b8f35fcf73255cd1d0df67607cd2/src/script/interpreter.cpp#L420
        let nSequenceTmp = try context.number(at: -1, pop: false)
        guard nSequenceTmp >= 0 else {
            throw OpCodeExcutionError.error("NEGATIVE_LOCKTIME")
        }
        let nSequence: UInt32 = UInt32(nSequenceTmp)

        guard let tx = context.transaction, let txin = context.txinToVerify else {
            throw OpCodeExcutionError.error("OP_CHECKLOCKTIMEVERIFY must have a transaction in context.")
        }

        let txToSequence = txin.sequence
        guard tx.version > 1 else {
            throw OpCodeExcutionError.error("Transaction's version number is not set high enough to trigger BIP 68 rules.")
        }

        let SEQUENCE_LOCKTIME_DISABLE_FLAG: UInt32 = (1 << 31)
        guard txToSequence & SEQUENCE_LOCKTIME_DISABLE_FLAG == 0 else {
            throw OpCodeExcutionError.error("SEQUENCE_LOCKTIME_DISABLE_FLAG is set.")
        }

        let SEQUENCE_LOCKTIME_TYPE_FLAG: UInt32 = (1 << 22)
        let SEQUENCE_LOCKTIME_MASK: UInt32 = 0x0000ffff
        let nLockTimeMask: UInt32 = SEQUENCE_LOCKTIME_TYPE_FLAG | SEQUENCE_LOCKTIME_MASK
        let txToSequenceMasked: UInt32 = txToSequence & nLockTimeMask
        let nSequenceMasked: UInt32 = nSequence & nLockTimeMask

        guard (txToSequenceMasked < SEQUENCE_LOCKTIME_TYPE_FLAG && nSequenceMasked < SEQUENCE_LOCKTIME_TYPE_FLAG) ||
            (txToSequenceMasked >= SEQUENCE_LOCKTIME_TYPE_FLAG && nSequenceMasked >= SEQUENCE_LOCKTIME_TYPE_FLAG) else {
                throw OpCodeExcutionError.error("txToSequenceMasked and nSequenceMasked should be the same kind.")
        }

        guard nSequence <= txToSequenceMasked  else {
            throw OpCodeExcutionError.error("The top stack item is greater than the transaction's nSequence field")
        }
    }
}
