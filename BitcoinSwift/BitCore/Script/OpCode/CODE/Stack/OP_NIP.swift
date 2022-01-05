//
//  OP_NIP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNip: OpCodeType {
    public var value: UInt8 { return 0x77 }
    public var name: String { return "OP_NIP" }
}
