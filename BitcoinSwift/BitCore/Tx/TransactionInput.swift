//
//  TransactionInput.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct TransactionInput {
    
    let prevTx: Data
    let prevIndex: UInt32
    let scriptSig: Script
    let sequence: UInt32
    
    init(prevTx: Data, prevIndex: UInt32, scriptSig: Script, sequence: UInt32 = 0xFFFFFFFF) {
        self.prevTx = prevTx
        self.prevIndex = prevIndex
        self.scriptSig = scriptSig
        self.sequence = sequence
    }
    
}
