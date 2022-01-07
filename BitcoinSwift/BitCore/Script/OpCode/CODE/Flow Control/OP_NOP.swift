//
//  OP_NOP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNop: OpCodeType {
    public var value: UInt8 { return 0x61 }
    public var name: String { return "OP_NOP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}
