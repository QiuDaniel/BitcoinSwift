//
//  OP_MAX.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpMax: OpCodeType {
    public var value: UInt8 { return 0xa4 }
    public var name: String { return "OP_MAX" }
}
