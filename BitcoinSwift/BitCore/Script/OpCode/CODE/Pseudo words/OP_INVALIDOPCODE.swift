//
//  OP_INVALIDOPCODE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpInvalidOpCode: OpCodeType {
    public var value: UInt8 { return 0xff }
    public var name: String { return "OP_INVALIDOPCODE" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        throw OpCodeExcutionError.error("OP_INVALIDOPCODE should not be executed.")
    }
}
