//
//  GetHeadersMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import Foundation

public struct GetHeadersMessage {
    
    public static let command = "getheaders"
    
    public let version: UInt32
    public let numHashes: Int
    public let startBlock: Data
    public let endBlock: Data
    
    init(version: UInt32 = 70015, numHashes: Int = 1, startBlock: Data, endBlock: Data? = nil) {
        self.version = version
        self.numHashes = numHashes
        self.startBlock = startBlock
        self.endBlock = endBlock == nil ? Data(repeating: 0, count: 32) : endBlock!
    }
    
    func serialize() -> Data {
        var result = version.littleEndian.data
        result += VarInt(numHashes).serialize()
        result += Data(startBlock.reversed())
        result += Data(endBlock.reversed())
        return result
    }
}
