//
//  OP_EQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpEqual: OpCodeType {
    public var value: UInt8 { return 0x87 }
    public var name: String { return "OP_EQUAL" }
}
