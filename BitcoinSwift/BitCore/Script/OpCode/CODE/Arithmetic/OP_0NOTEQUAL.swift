//
//  OP_0NOTEQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/4.
//

import Foundation

public struct OP0NotEqual: OpCodeType {
    public var value: UInt8 {
        return 0x92
    }
    
    public var name: String {
        return "OP_0NOTEQUAL"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let input = try context.number(at: -1)
        context.push(input != 0)
    }
}
