//
//  TransactionOut.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct TransactionOutput {
    
    let amount: UInt64
    let scriptPubkey: Script
    
    init(amount: UInt64, scriptPubkey: Script) {
        self.amount = amount
        self.scriptPubkey = scriptPubkey
    }
    
}
