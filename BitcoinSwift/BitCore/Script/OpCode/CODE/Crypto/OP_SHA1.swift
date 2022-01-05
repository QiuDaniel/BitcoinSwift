//
//  OP_SHA1.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSha1: OpCodeType {
    public var value: UInt8 { return 0xa7 }
    public var name: String { return "OP_SHA1" }
}