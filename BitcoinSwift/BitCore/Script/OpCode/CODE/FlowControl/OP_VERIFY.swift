//
//  OP_VERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpVerify: OpCodeType {
    public var value: UInt8 { return 0x69 }
    public var name: String { return "OP_VERIFY" }
}
