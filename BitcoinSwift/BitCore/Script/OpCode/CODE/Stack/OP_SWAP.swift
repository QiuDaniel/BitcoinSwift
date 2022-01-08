//
//  OP_SWAP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSwap: OpCodeType {
    public var value: UInt8 { return 0x7c }
    public var name: String { return "OP_SWAP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        context.swapAt(i: -2, j: -1)
    }
}
