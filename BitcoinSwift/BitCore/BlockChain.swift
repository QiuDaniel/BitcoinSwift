//
//  BlockChain.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/10.
//

import Foundation

public struct BlockChain {
    let network: Network
    let store: BlockStore
    
    public func addBlock(_ message: BlockMessage) throws {
        try store.addBlock(message)
    }
    
    public func addMerkleBlock(_ merkleBlock: MerkleBlock, hash: Data) throws {
        try store.addMerkleBlock(merkleBlock, hash: hash)
    }
    
    public func addTransaction(_ transaction: Transaction) throws {
        try store.addTransaction(transaction)
    }
    
    public func calculateBalance(_ address: String) throws -> Int64 {
        return try store.calculateBalance(address: address)
    }
    
    public func latestBlockHash() -> Data {
        guard let hash = try? store.latestBlockHash() else {
            return network.checkPoints.last!.hash
        }
        return hash
    }
}
