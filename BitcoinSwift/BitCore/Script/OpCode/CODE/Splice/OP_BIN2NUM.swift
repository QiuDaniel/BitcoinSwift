//
//  OP_BIN2NUM.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpBin2Num: OpCodeType {
    public var value: UInt8 { return 0x81 }
    public var name: String { return "OP_BIN2NUM" }
}