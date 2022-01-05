//
//  Transaction.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct Transaction {
    
    let version: UInt32
    let inputs: [TransactionInput]
    let outputs: [TransactionOutput]
    let lockTime: UInt32
    
    init(version: UInt32, inputs: [TransactionInput], outputs: [TransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
    }
    
}

extension Transaction: CustomStringConvertible {
    public var description: String {
        return ""
    }
}
