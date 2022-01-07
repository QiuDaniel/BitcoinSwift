//
//  OP_VER.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpVer: OpCodeType {
    public var value: UInt8 { return 0x62 }
    public var name: String { return "OP_VER" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        throw OpCodeExcutionError.error("OP_VER should not be executed.")
    }
}
