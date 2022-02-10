//
//  BlockMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/8.
//

import Foundation

public struct BlockMessage {
    
    public static let command = "block"
    
    public let block: Block
    public let txs: [Transaction]
    
    public func serialize() -> Data {
        var result = block.serialize()
        result += txs.flatMap{ $0.serialize() }
        return result
    }
    
    public static func parse(_ stream: ByteStream) -> Self {
        let block = Block.parse(stream)
        let count = stream.read(VarInt.self).underlyingValue
        var txs = [Transaction]()
        for _ in 0..<count {
            txs.append(Transaction.parse(stream))
        }
        return .init(block: block, txs: txs)
    }
}
