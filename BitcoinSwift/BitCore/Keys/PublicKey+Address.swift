//
//  PublicKey+Address.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

extension PublicKey {
    func toBitcoinAddress() -> BitcoinAddress {
        let hash160 = Crypto.hash160(data)
        return BitcoinAddress(data: hash160, network: network)
    }
}
