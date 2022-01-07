//
//  OP_CHECKLOCKTIMEVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckLockTimeVerify: OpCodeType {
    public var value: UInt8 { return 0xb1 }
    public var name: String { return "OP_CHECKLOCKTIMEVERIFY " }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let nLockTime = try context.number(at: -1, pop: false)
        
        // nLockTime should be Int5
        // reference: https://github.com/Bitcoin-ABC/bitcoin-abc/blob/73c5e7532e19b8f35fcf73255cd1d0df67607cd2/src/script/interpreter.cpp#L420
        guard nLockTime >= 0 else {
            throw OpCodeExcutionError.error("NEGATIVE_LOCKTIME")
        }
        guard let tx = context.transaction, let txin = context.txinToVerify else {
            throw OpCodeExcutionError.error("OP_CHECKLOCKTIMEVERIFY must have a transaction in context.")
        }
        
        guard (tx.lockTime < BTC_LOCKTIME_THRESHOLD && nLockTime < BTC_LOCKTIME_THRESHOLD) ||
            (tx.lockTime >= BTC_LOCKTIME_THRESHOLD && nLockTime >= BTC_LOCKTIME_THRESHOLD) else {
            throw OpCodeExcutionError.error("tx.lockTime and nLockTime should be the same kind.")
        }
        
        guard nLockTime <= tx.lockTime  else {
            throw OpCodeExcutionError.error("The top stack item is greater than the transaction's nLockTime field")
        }
        
        
        let SEQUENCE_FINAL: UInt32 = 0xffffffff
        guard txin.sequence != SEQUENCE_FINAL else {
            throw OpCodeExcutionError.error("The input's nSequence field is equal to 0xffffffff.")
        }
    }
}
