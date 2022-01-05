//
//  OP_BOOLAND.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpBoolAnd: OpCodeType {
    public var value: UInt8 {
        return 0x9a
    }
    
    public var name: String {
        return "OP_BOOLAND"
    }
}
