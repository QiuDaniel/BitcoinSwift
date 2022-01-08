//
//  OP_IFDUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpIfDup: OpCodeType {
    public var value: UInt8 { return 0x73 }
    public var name: String { return "OP_IFDUP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        if context.bool(at: -1, pop: false) {
            try context.push(context.data(at: -1, pop: false))
        }
    }
}
