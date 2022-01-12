//
//  OP_SIZE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSize: OpCodeType {
    public var value: UInt8 { return 0x82 }
    public var name: String { return "OP_SIZE" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let element = context.data(at: -1, pop: false)
        context.push(Int32(element.count))
    }
}
