//
//  OP_IFDUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpIfDup: OpCodeType {
    public var value: UInt8 { return 0x73 }
    public var name: String { return "OP_IFDUP" }
}
