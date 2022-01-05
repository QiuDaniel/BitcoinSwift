//
//  OP_WITHIN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpWithin: OpCodeType {
    public var value: UInt8 { return 0xa5 }
    public var name: String { return "OP_WITHIN" }
}
