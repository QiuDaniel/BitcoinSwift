//
//  OP_TUCK.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation


public struct OpTuck: OpCodeType {
    public var value: UInt8 { return 0x7d }
    public var name: String { return "OP_TUCK" }
}
