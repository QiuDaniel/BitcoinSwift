//
//  BitcoinAddress.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public enum AddressError: Error {
    case invalid
    case invalidScheme
    case invalidVersionByte
    case invalidDataSize
}

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
    
    init(_ legacy: String) throws {
        guard let pubkeyHash = Base58Check.decode(legacy) else {
            throw AddressError.invalid
        }
        
        let networkVersionByte = pubkeyHash[0]
        switch networkVersionByte {
        case Network.BTCmainnet.pubkeyHash, Network.BTCmainnet.scriptHash:
            network = .BTCmainnet
        case Network.BTCtestnet.pubkeyHash, Network.BTCtestnet.scriptHash:
            network = .BTCtestnet
        default:
            throw AddressError.invalidVersionByte
        }
        
        switch networkVersionByte {
        case Network.BTCmainnet.pubkeyHash, Network.BTCtestnet.pubkeyHash:
            hashType = .pubkeyHash
        case Network.BTCmainnet.scriptHash, Network.BTCtestnet.scriptHash:
            hashType = .scriptHash
        default:
            throw AddressError.invalidVersionByte
        }
        self.data = pubkeyHash.dropFirst()
        
        guard data.count == 20 else {
            throw AddressError.invalid
        }
        
    }
}
