//
//  OP_2DROP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Drop: OpCodeType {
    public var value: UInt8 { return 0x6d }
    public var name: String { return "OP_2DROP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        context.remove(at: -1)
        context.remove(at: -1)
    }
}
