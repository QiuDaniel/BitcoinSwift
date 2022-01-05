//
//  OP_2OVER.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Over: OpCodeType {
    public var value: UInt8 { return 0x70 }
    public var name: String { return "OP_2OVER" }
}
