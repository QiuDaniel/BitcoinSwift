//
//  CoinType.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/27.
//

import Foundation

/// BIP44 cointype value
public struct CoinType {
    let index: UInt32
    let symbol: String
    let name: String
}

extension CoinType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.index == rhs.index && lhs.symbol == rhs.symbol && lhs.name == rhs.name
    }
}

extension CoinType {
    static let testnet = CoinType(index: 1, symbol: "", name: "Testnet (all coins)")
    static let btc = CoinType(index: 0, symbol: "BTC", name: "Bitcoin")
}
