//
//  OP_INVERT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpInvert: OpCodeType {
    public var value: UInt8 { return 0x83 }
    public var name: String { return "OP_INVERT" }

    public var isEnabled: Bool {
        return false
    }
}
