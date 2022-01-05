//
//  OP_RETURN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpReturn: OpCodeType {
    public var value: UInt8 { return 0x6a }
    public var name: String { return "OP_RETURN" }
}
