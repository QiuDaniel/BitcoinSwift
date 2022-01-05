//
//  OP_RIPEMD160.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpRipemd160: OpCodeType {
    public var value: UInt8 { return 0xa6 }
    public var name: String { return "OP_RIPEMD160" }
}
