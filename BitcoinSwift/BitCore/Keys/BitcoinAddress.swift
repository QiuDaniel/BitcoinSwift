//
//  BitcoinAddress.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct BitcoinAddress {
    
    public enum HashType: UInt8 {
        case pubkeyHash = 0
        case scriptHash = 8
    }
    
    let data: Data
    let network: Network
    let hashType: HashType
    
    var legacy: String {
        switch hashType {
        case .pubkeyHash:
            return Base58Check.encode([network.pubkeyHash] + data)
        case .scriptHash:
            return Base58Check.encode([network.scriptHash] + data)
        }
    }
    
    /// the data ought to be hash160
    init(data: Data, network: Network, hashType: HashType = .pubkeyHash) {
        self.data = data
        self.network = network
        self.hashType = hashType
    }
}
