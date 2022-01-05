//
//  OP_1SUB.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op1Sub: OpCodeType {
    public var value: UInt8 {
        return 0x8c
    }
    
    public var name: String {
        return "OP_1SUB"
    }
}
