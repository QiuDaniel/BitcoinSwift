//
//  OP_CHECKMULTISIGVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckMultiSigVerify: OpCodeType {
    public var value: UInt8 { return 0xaf }
    public var name: String { return "OP_CHECKMULTISIGVERIFY" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try OPCode.OP_CHECKMULTISIG.excuteProcess(context)
        do {
            try OPCode.OP_VERIFY.excuteProcess(context)
        } catch {
            throw OpCodeExcutionError.error("OP_CHECKMULTISIGVERIFY failed.")
        }
    }
}
