//
//  OP_2SWAP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Swap: OpCodeType {
    public var value: UInt8 { return 0x72 }
    public var name: String { return "OP_2SWAP" }
    
    // input : x1 x2 x3 x4
    // output : x3 x4 x1 x2
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(4)
        context.swapAt(i: -4, j: -2)
        context.swapAt(i: -3, j: -1)
    }
}
