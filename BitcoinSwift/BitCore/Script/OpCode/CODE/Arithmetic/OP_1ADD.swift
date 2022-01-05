//
//  OP_1ADD.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op1Add: OpCodeType {
    public var value: UInt8 {
        return 0x8b
    }
    
    public var name: String {
        return "OP_1ADD"
    }
}
