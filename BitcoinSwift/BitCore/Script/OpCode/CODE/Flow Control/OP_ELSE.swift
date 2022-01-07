//
//  OP_ELSE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpElse: OpCodeType {
    public var value: UInt8 { return 0x67 }
    public var name: String { return "OP_ELSE" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        guard !context.conditionStack.isEmpty else {
            throw OpCodeExcutionError.error("Expected an OP_IF or OP_NOTIF branch before OP_ELSE.")
        }
        let f = context.conditionStack.removeLast()
        context.conditionStack.append(!f)
    }
}
