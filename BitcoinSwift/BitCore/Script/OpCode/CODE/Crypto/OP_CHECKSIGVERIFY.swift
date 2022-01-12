//
//  OP_CHECKSIGVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckSigVerify: OpCodeType {
    public var value: UInt8 { return 0xad }
    public var name: String { return "OP_CHECKSIGVERIFY" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try OPCode.OP_CHECKSIG.excuteProcess(context)
        do {
            try OPCode.OP_VERIFY.excuteProcess(context)
        } catch {
            throw OpCodeExcutionError.error("OP_CHECKSIGVERIFY failed.")
        }
    }
}
