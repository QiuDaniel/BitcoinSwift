//
//  OP_NUMEQUALVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNumEqualVerify: OpCodeType {
    public var value: UInt8 { return 0x9d }
    public var name: String { return "OP_NUMEQUALVERIFY" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try OPCode.OP_NUMEQUAL.excuteProcess(context)
        do {
            try OPCode.OP_VERIFY.excuteProcess(context)
        } catch {
            throw OpCodeExcutionError.error("OP_NUMEQUALVERIFY failed.")
        }
    }
}
