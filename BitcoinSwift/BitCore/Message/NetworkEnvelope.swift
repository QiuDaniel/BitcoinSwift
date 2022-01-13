//
//  NetworkEnvelope.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/11.
//

import Foundation

public enum NetworkEnvelopeError: Error {
    case error(String)
}

public struct NetworkEnvelope {
    
    public static let minimumLength = 24
    
    public let magic: UInt32
    public let command: String
    public let payload: Data
    public let network: Network
    
    init(command: String, payload: Data, network: Network = .BTCmainnet) {
        self.command = command
        self.payload = payload
        self.network = network
        self.magic = network.magic
    }
    
    func serialize() -> Data {
        var result = magic.bigEndian.data
        var bytes = command.toData().bytes
        bytes.append(contentsOf: [UInt8](repeating: 0, count: 12 - bytes.count))
        result += bytes
        let payloadLength = UInt32(payload.count).littleEndian
        result += payloadLength.data
        let checksum = Crypto.hash256(payload).prefix(maxCount: 4)
        result += checksum
        result += payload
        return result
    }
    
    static func parse(_ stream: ByteStream, network: Network = .BTCmainnet) throws -> Self {
        let magic = stream.read(UInt32.self)
        let expectedMagic = network.magic.bigEndian // mac 
        guard magic == expectedMagic else {
            throw NetworkEnvelopeError.error("magic is not right \(magic) vs \(expectedMagic)")
        }
        let command = stream.read(Data.self, count: 12).to(String.self)
        let payloadLength = stream.read(UInt32.self)
        let checksum = stream.read(Data.self, count: 4)
        guard payloadLength <= stream.availableByteCount else {
            throw NetworkEnvelopeError.error("data length does not match")
        }
        let payload = stream.read(Data.self, count: Int(payloadLength))
        let calculatedSum = Crypto.hash256(payload).prefix(maxCount: 4)
        guard checksum == calculatedSum else {
            throw NetworkEnvelopeError.error("checksum does not match")
        }
        return .init(command: command, payload: payload, network: network)
    }
    
}

extension NetworkEnvelope: CustomStringConvertible {
    public var description: String {
        return "\(self.command): \(self.payload.hex)"
    }
}

enum MessageError: Error {
    case error(String)
}
