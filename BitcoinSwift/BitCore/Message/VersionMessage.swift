//
//  VersionMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import Foundation

public struct VersionMessage {
    
    public static let command = "version"
    
    public let version: Int32
    public let services: UInt64
    public let timestamp: Int64
    public let receiverAddress: NetworkAddress
    public let senderAddress: NetworkAddress
    public let nonce: UInt64
    public let userAgent: String
    public let latestBlock: Int32
    public let relay: Bool
    
    init(version: Int32 = 70015, services: UInt64 = 0, timestamp: Int64? = nil, receiverAddress: NetworkAddress = .default, senderAddress: NetworkAddress = .default, nonce: UInt64? = nil, userAgent: String = "/BitcoinSwift:0.0.1/", latestBlock: Int32 = 0, relay: Bool = false) {
        self.version = version
        self.services = services
        self.timestamp = timestamp == nil ? Int64(Date().timeIntervalSince1970) : timestamp!
        self.receiverAddress = receiverAddress
        self.senderAddress = senderAddress
        self.nonce = nonce == nil ? UInt64.random() : nonce!
        self.userAgent = userAgent
        self.latestBlock = latestBlock
        self.relay = relay
    }
    
    func serialaize() -> Data {
        var result = version.littleEndian.data
        result += services.littleEndian.data
        result += timestamp.littleEndian.data
        result += receiverAddress.seriailze()
        result += senderAddress.seriailze()
        result += nonce.littleEndian.data
        let stringData = userAgent.toData()
        result += VarInt(stringData.count).serialize()
        result += stringData
        result += latestBlock.littleEndian.data
        result += relay ? Data(0x01) : Data(0x00)
        return result
    }
    
    static func parse(_ stream: ByteStream) -> Self {
        let version = stream.read(Int32.self)
        let services = stream.read(UInt64.self)
        let timestamp = stream.read(Int64.self)
        let receiverAddres = NetworkAddress.parse(stream)
        guard stream.availableByteCount > 0 else {
            return .init(version: version, services: services, timestamp: timestamp, receiverAddress: receiverAddres)
        }
        let senderAddress = NetworkAddress.parse(stream)
        let nonce = stream.read(UInt64.self)
        let userAgentLength = stream.read(VarInt.self).underlyingValue
        let userAgentData = stream.read(Data.self, count: Int(userAgentLength))
        let userAgent = userAgentData.to(String.self)
        let latestBlock = stream.read(Int32.self)
        guard stream.availableByteCount > 0 else {
            return .init(version: version, services: services, timestamp: timestamp, receiverAddress: receiverAddres, senderAddress: senderAddress, nonce: nonce, userAgent: userAgent, latestBlock: latestBlock)
        }
        let relay = stream.read(Bool.self)
        
        return .init(version: version, services: services, timestamp: timestamp, receiverAddress: receiverAddres, senderAddress: senderAddress, nonce: nonce, userAgent: userAgent, latestBlock: latestBlock, relay: relay)
    }
}

// https://stackoverflow.com/questions/24007129/how-does-one-generate-a-random-number-in-swift
private func arc4random<T: ExpressibleByIntegerLiteral>(_ type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, MemoryLayout<T>.size)
    return r
}

private extension UInt64 {
    static func random(lower: UInt64 = min, upper: UInt64 = max) -> UInt64 {
        var m: UInt64
        let u = upper - lower
        var r = arc4random(UInt64.self)

        if u > UInt64(Int64.max) {
            m = 1 + ~u
        } else {
            m = ((max - (u * 2)) + 1) % u
        }

        while r < m {
            r = arc4random(UInt64.self)
        }

        return (r % u) + lower
    }
}
