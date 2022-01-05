//
//  OP_CHECKSIGVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckSigVerify: OpCodeType {
    public var value: UInt8 { return 0xad }
    public var name: String { return "OP_CHECKSIGVERIFY" }
}
