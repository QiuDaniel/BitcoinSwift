//
//  OP_NUMNOTEQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNumNotEqual: OpCodeType {
    public var value: UInt8 { return 0xe }
    public var name: String { return "OP_NUMNOTEQUAL" }
}
