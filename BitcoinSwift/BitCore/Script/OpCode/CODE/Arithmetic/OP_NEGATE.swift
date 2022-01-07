//
//  OP_NEGATE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNegate: OpCodeType {
    public var value: UInt8 { return 0x8f }
    public var name: String { return "OP_NEGATE" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let input = try context.number(at: -1)
        context.push(-input)
    }
    
}
