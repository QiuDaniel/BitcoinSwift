//
//  OP_2DIV.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// The input is divided by 2. disabled.
public struct Op2Div: OpCodeType {
    public var value: UInt8 {
        return 0x8e
    }
    
    public var name: String {
        return "OP_2DIV"
    }
    
    public var isEnabled: Bool {
        return false
    }
}
