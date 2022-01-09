//
//  OPCode+Static.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public extension OPCode {
    
    
    /// Returns the OPCode which a given UInt8 value.
    /// Returns OP_INVALIDOPCODE for outranged value.
    /// - Parameter value: UInt8 value corresponding to the OPCode
    /// - Returns: The OPCode corresponding to value
    static func parse(_ value: UInt8) -> Self {
        return OPCode.allCases.first { $0.value == value } ?? .OP_INVALIDOPCODE
    }
    
    ///  Returns the OPCode which a given name.
    ///  Returns OP_INVALIDOPCODE for unknown names.
    /// - Parameter name: String corresponding to the OPCode
    /// - Returns: The OPCode corresponding to name
    static func parse(_ name: String) -> Self {
        return OPCode.allCases.first { $0.name == name } ?? .OP_INVALIDOPCODE
    }
    
    
    /// Returns OP_1NEGATE, OP_0 .. OP_16 for ints from -1 to 16.
    /// Returns OP_INVALIDOPCODE for other ints.
    /// - Parameter integer: Int value from -1 to 16
    /// - Returns: The OPCode corresponding to integer
    static func parseSmallInteger(_ integer: Int) -> Self {
        switch integer {
        case -1:
            return .OP_1NEGATE
        case 0:
            return .OP_0
        case 1...16:
            return self.parse(OPCode.OP_1.value + UInt8(integer - 1))
        default:
            return .OP_INVALIDOPCODE
        }
    }
}
