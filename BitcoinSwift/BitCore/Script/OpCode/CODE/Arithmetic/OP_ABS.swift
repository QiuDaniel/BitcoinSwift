//
//  OP_ABS.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpAbs: OpCodeType {
    public var value: UInt8 {
        return 0x90
    }
    
    public var name: String {
        return "OP_ABS"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let input = try context.number(at: -1)
        context.push(abs(input))
    }
}
