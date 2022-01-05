//
//  OP_MIN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpMin: OpCodeType {
    public var value: UInt8 { return 0xa3 }
    public var name: String { return "OP_MIN" }
}
