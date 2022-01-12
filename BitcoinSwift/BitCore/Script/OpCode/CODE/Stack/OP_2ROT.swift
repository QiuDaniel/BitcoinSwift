//
//  OP_2ROT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Rot: OpCodeType {
    public var value: UInt8 { return 0x7b }
    public var name: String { return "OP_2ROT" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(6)
        let x1 = context.data(at: -6, pop: false)
        let x2 = context.data(at: -5, pop: false)
        let count = context.stack.count
        context.stack.removeSubrange(count-6..<count-4)
        try context.push(x1)
        try context.push(x2)
    }
}
