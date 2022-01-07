//
//  OP_EQUALVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpEqualVerify: OpCodeType {
    public var value: UInt8 { return 0x88 }
    public var name: String { return "OP_EQUALVERIFY" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try OPCode.OP_EQUAL.excuteProcess(context)
        do {
            try OPCode.OP_VERIFY.excuteProcess(context)
        } catch {
            throw OpCodeExcutionError.error("OP_EQUALVERIFY failed.")
        }
    }
}
