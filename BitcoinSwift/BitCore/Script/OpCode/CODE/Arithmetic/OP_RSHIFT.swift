//
//  OP_RSHIFT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// (x y -- x>>y) disabled.
public struct OpRShift: OpCodeType {
    public var value: UInt8 { return 0x99 }
    public var name: String { return "OP_RSHIFT" }
    
    public var isEnabled: Bool { return false }
}
