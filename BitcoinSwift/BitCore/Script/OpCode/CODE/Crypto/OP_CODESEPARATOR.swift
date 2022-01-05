//
//  OP_CODESEPARATOR.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCodeSeparator: OpCodeType {
    public var value: UInt8 { return 0xab }
    public var name: String { return "OP_CODESEPARATOR" }
}
