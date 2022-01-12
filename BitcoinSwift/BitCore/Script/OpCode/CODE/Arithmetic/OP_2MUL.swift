//
//  OP_2MUL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Mul: OpCodeType {
    public var value: UInt8 {
        return 0x8d
    }
    
    public var name: String {
        return "OP_2MUL"
    }
    
    public var isEnabled: Bool {
        return false
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)

        let input = try context.number(at: -1)
        context.push(input * 2)
    }
}
