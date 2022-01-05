//
//  OP_GREATERTHAN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpGreaterThan: OpCodeType {
    public var value: UInt8 { return 0xa0 }
    public var name: String { return "OP_GREATERTHAN" }
}
