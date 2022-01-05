//
//  OP_ELSE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpElse: OpCodeType {
    public var value: UInt8 { return 0x67 }
    public var name: String { return "OP_ELSE" }
}
