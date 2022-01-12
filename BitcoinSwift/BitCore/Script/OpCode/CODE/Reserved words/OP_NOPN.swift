//
//  OP_NOPN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNop1: OpCodeType {
    public var value: UInt8 { return 0xb0 }
    public var name: String { return "OP_NOP1" }

//    public func mainProcess(_ context: ScriptExecutionContext) throws {
//        // do nothing
//    }
}

public struct OpNop4: OpCodeType {
    public var value: UInt8 { return 0xb3 }
    public var name: String { return "OP_NOP4" }

    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}

public struct OpNop5: OpCodeType {
    public var value: UInt8 { return 0xb4 }
    public var name: String { return "OP_NOP5" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}

public struct OpNop6: OpCodeType {
    public var value: UInt8 { return 0xb5 }
    public var name: String { return "OP_NOP6" }

    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}

public struct OpNop7: OpCodeType {
    public var value: UInt8 { return 0xb6 }
    public var name: String { return "OP_NOP8" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}

public struct OpNop8: OpCodeType {
    public var value: UInt8 { return 0xb7 }
    public var name: String { return "OP_NOP8" }

    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}

public struct OpNop9: OpCodeType {
    public var value: UInt8 { return 0xb8 }
    public var name: String { return "OP_NOP9" }

    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}

public struct OpNop10: OpCodeType {
    public var value: UInt8 { return 0xb9 }
    public var name: String { return "OP_NOP10" }

    public func excuteProcess(_ context: ScriptExcutionContext) throws {}
}
