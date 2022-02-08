//
//  GetBlocksMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/8.
//

import Foundation

public struct GetBlocksMessage {
    public static let command = "getblocks"
    
    public let version: UInt32
    /// number of block locator hash entries
    public let hashCount: Int
    /// block locator object; newest back to genesis block (dense to start, but then sparse)
    public let blockLocator: Data
    /// hash of the last desired block; set to zero to get as many blocks as possible (500)
    public let hashStop: Data
    
    func serialize() -> Data {
        var result = version.littleEndian.data
        result += VarInt(hashCount).serialize()
        result += blockLocator
        result += hashStop
        return result
    }
    
}
