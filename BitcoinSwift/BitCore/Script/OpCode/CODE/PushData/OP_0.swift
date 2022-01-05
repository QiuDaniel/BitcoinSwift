//
//  OP_0.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op0: OpCodeType {
    public var value: UInt8 { return 0x00 }
    public var name: String { return "OP_0" }
}
