//
//  OP_ADD.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpAdd: OpCodeType {
    public var value: UInt8 {
        return 0x93
    }
    
    public var name: String {
        return "OP_Add"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let input1 = try context.number(at: -1)
        let input2 = try context.number(at: -1)
        context.push(input1 + input2)
    }
}
