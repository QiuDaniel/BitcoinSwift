//
//  OP_MUL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// (x y -- x*y) disabled
public struct OpMul: OpCodeType {
    public var value: UInt8 { return 0x95 }
    public var name: String { return "OP_MUL" }

    public var isEnabled: Bool {
        return false
    }
}
