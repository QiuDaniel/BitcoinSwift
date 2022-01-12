//
//  OpcodeType.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import Foundation

public protocol OpCodeType {
    var name: String { get }
    var value: UInt8 { get }
    var isEnabled: Bool { get }
    
    func excuteProcess(_ context: ScriptExcutionContext) throws
}

extension OpCodeType {
    
    public var isEnabled: Bool {
        return true
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        throw OpCodeExcutionError.notImplemented("[\(name)(\(value))]")
    }
    
    public func excute(_ context: ScriptExcutionContext) throws {
        try preProcess(context)
        guard context.shouldExcute || (OPCode.OP_IF <= self && self <= OPCode.OP_ENDIF) else {
            if context.verbose {
                print("[SKIP execution :  \(name)(\(value))]\n" + String(repeating: "-", count: 100))
            }
            return
        }
        if context.verbose {
            print("OPCount : \(context.opCount)\n[pre excution : \(name)(\(value))]\n\(context)")
        }
        try excuteProcess(context)
        if context.verbose {
            print("[post execution : \(name)(\(value))]\n\(context)\n" + String(repeating: "-", count: 100))
        }
    }
}

private extension OpCodeType {
    
    func preProcess(_ context: ScriptExcutionContext) throws {
        if value > OPCode.OP_16 {
            try context.incrementOpCount()
        }
        guard isEnabled else {
            throw OpCodeExcutionError.disabled
        }
        
        guard !(context.shouldExcute && 0 <= value && value <= OPCode.OP_PUSHDATA4.value) else {
            throw OpCodeExcutionError.error("PUSHDATA OP_CODE should not be executed.")
        }
    }
    
}

public enum OpCodeExcutionError: Error {
    case notImplemented(String)
    case error(String)
    case opcodeRequiresItemsOnStack(Int)
    case invalidBigNumber
    case disabled
}

// ==
public func == (lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value == rhs.value
}
public func == <Other: BinaryInteger>(lhs: OpCodeType, rhs: Other) -> Bool {
    return lhs.value == rhs
}
public func == <Other: BinaryInteger>(lhs: Other, rhs: OpCodeType) -> Bool {
    return lhs == rhs.value
}

// !=
public func != (lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value != rhs.value
}
public func != <Other: BinaryInteger>(lhs: OpCodeType, rhs: Other) -> Bool {
    return lhs.value != rhs
}
public func != <Other: BinaryInteger>(lhs: Other, rhs: OpCodeType) -> Bool {
    return lhs != rhs.value
}

// >
public func >(lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value > rhs.value
}
public func ><Other: BinaryInteger>(lhs: OpCodeType, rhs: Other) -> Bool {
    return lhs.value > rhs
}
public func ><Other: BinaryInteger>(lhs: Other, rhs: OpCodeType) -> Bool {
    return lhs > rhs.value
}

// <
public func <(lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value < rhs.value
}
public func <<Other: BinaryInteger>(lhs: OpCodeType, rhs: Other) -> Bool {
    return lhs.value < rhs
}
public func <<Other: BinaryInteger>(lhs: Other, rhs: OpCodeType) -> Bool {
    return lhs < rhs.value
}

// >=
public func >=(lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value >= rhs.value
}

// <=
public func <=(lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value <= rhs.value
}

// ...
public func ... (lhs: OpCodeType, rhs: OpCodeType) -> Range<UInt8> {
    return Range(lhs.value...rhs.value)
}

// ~=
public func ~= (pattern: OpCodeType, op: OpCodeType) -> Bool {
    return pattern == op
}
public func ~= (pattern: Range<UInt8>, op: OpCodeType) -> Bool {
    return pattern ~= op.value
}

