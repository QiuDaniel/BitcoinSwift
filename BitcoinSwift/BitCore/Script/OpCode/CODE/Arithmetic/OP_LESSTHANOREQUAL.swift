//
//  OP_LESSTHANOREQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpLessThanOrEqual: OpCodeType {
    public var value: UInt8 { return 0xa1 }
    public var name: String { return "OP_LESSTHANOREQUAL" }
}
