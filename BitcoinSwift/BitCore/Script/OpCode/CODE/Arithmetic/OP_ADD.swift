//
//  OP_ADD.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpAdd: OpCodeType {
    public var value: UInt8 {
        return 0x93
    }
    
    public var name: String {
        return "OP_Add"
    }
}
