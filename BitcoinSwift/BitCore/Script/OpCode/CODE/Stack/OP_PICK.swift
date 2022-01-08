//
//  OP_PICK.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpPick: OpCodeType {
    public var value: UInt8 { return 0x79 }
    public var name: String { return "OP_PICK" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let n = try context.number(at: -1)
        guard n >= 0 else {
            throw OpCodeExcutionError.error("\(name): n should be greater than or equal to 0.")
        }
        
        let index = Int(n + 1)
        try context.assertStackHeightGreaterThanOrEqual(index)
        let xn = context.data(at: -index, pop: false)
        try context.push(xn)
    }
}
