//
//  OP_TUCK.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation


public struct OpTuck: OpCodeType {
    public var value: UInt8 { return 0x7d }
    public var name: String { return "OP_TUCK" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let data = context.data(at: -1, pop: false)
        context.insert(data, at: -2)
    }
}
