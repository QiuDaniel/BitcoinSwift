//
//  OP_LSHIFT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// (x y -- x<<y) disabled.
public struct OpLShift: OpCodeType {
    public var value: UInt8 { return 0x98 }
    public var name: String { return "OP_LSHIFT" }

    public var isEnabled: Bool {
        return false
    }
    
}
