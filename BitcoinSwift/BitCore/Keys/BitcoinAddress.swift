//
//  BitcoinAddress.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public struct BitcoinAddress {
    
    let data: Data
    let network: Network
    
    var legacy: String {
        return Base58Check.encode([network.pubkeyHash] + data)
    }
    
    /// the data ought to be hash160
    init(data: Data, network: Network) {
        self.data = data
        self.network = network
    }
}
