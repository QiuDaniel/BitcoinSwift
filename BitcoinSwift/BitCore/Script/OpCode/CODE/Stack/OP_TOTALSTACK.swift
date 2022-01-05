//
//  OP_TOTALSTACK.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpToAltStack: OpCodeType {
    public var value: UInt8 { return 0x6b }
    public var name: String { return "OP_TOALTSTACK" }
}
