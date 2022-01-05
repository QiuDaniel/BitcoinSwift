//
//  OP_NUM2BIN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNum2Bin: OpCodeType {
    public var value: UInt8 { return 0x80 }
    public var name: String { return "OP_NUM2BIN" }
}
