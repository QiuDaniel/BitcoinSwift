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
}

extension OpCodeType {
    public var isEnabled: Bool {
        return true
    }
}

public enum OpCodeExecutionError: Error {
    case notImplemented(String)
    case error(String)
    case opcodeRequiresItemOnStack(Int)
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
public func > (lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value > rhs.value
}
public func > <Other: BinaryInteger>(lhs: OpCodeType, rhs: Other) -> Bool {
    return lhs.value > rhs
}
public func > <Other: BinaryInteger>(lhs: Other, rhs: OpCodeType) -> Bool {
    return lhs > rhs.value
}

// <
public func < (lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value < rhs.value
}
public func < <Other: BinaryInteger>(lhs: OpCodeType, rhs: Other) -> Bool {
    return lhs.value < rhs
}
public func < <Other: BinaryInteger>(lhs: Other, rhs: OpCodeType) -> Bool {
    return lhs < rhs.value
}

// >=
public func >= (lhs: OpCodeType, rhs: OpCodeType) -> Bool {
    return lhs.value >= rhs.value
}

// <=
public func <= (lhs: OpCodeType, rhs: OpCodeType) -> Bool {
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

