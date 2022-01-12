//
//  OP_BOOLOR.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpBoolOr: OpCodeType {
    public var value: UInt8 {
        return 0x9b
    }
    
    public var name: String {
        return "OP_BOOLOR"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = context.data(at: -1)
        let x2 = context.data(at: -1)
        context.push(x1 != .empty || x2 != .empty)
    }
}
