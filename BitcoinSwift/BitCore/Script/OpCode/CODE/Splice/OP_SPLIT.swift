//
//  OP_SPLIT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// bitcoin cash
public struct OpSplit: OpCodeType {
    public var value: UInt8 { return 0x7f }
    public var name: String { return "OP_SPLIT" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let position = try context.number(at: -1)
        let data = context.data(at: -1)
        guard position < data.count else {
            throw OpCodeExcutionError.error("Invalid OP_SPLIT range")
        }
        
        let x1 = data.subdata(in: 0..<Int(position))
        let x2 = data.subdata(in: Int(position)..<data.count)
        try context.push(x1)
        try context.push(x2)
    }
}
