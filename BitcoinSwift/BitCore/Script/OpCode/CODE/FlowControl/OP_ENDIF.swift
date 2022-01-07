//
//  OP_ENDIF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpEndIf: OpCodeType {
    public var value: UInt8 { return 0x68 }
    public var name: String { return "OP_ENDIF" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        guard !context.conditionStack.isEmpty else {
            throw OpCodeExcutionError.error("Expected an OP_IF or OP_NOTIF branch before OP_ENDIF.")
        }
        context.conditionStack.removeLast()
    }
}
