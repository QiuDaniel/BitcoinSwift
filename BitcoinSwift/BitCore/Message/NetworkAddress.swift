//
//  NetworkAddress.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import Foundation

public struct NetworkAddress {
    
    public static let `default` = NetworkAddress(services: 0, ip: Data(repeating: 0, count: 4), port: 8_333)
    
    public let services: UInt64
    public let ip: Data
    public let port: UInt16
    
    
    public func seriailze() -> Data {
        var result = services.littleEndian.data
        if ip.count == 16 {
            result += ip
        } else {
            result += (Data(repeating: 0, count: 10) + Data(repeating: 0xff, count: 2) + ip)
        }
        result += port.bigEndian.data
        return result
    }
    
    static func parse(_ stream: ByteStream) -> NetworkAddress {
        let services = stream.read(UInt64.self)
        let data = stream.read(Data.self, count: 16)
        let ip: Data
        if data[0..<12] == (Data(repeating: 0, count: 10) + Data(repeating: 0xff, count: 2)) {
            ip = data.dropFirst(12)
        } else {
            ip = data
        }
        let port = stream.read(UInt16.self)
        return .init(services: services, ip: ip, port: port)
    }
    
    static func parseIP(data: Data) -> String {
        let address = ipv6(from: data)
        if address.hasPrefix("0000:0000:0000:0000:0000:ffff") {
            return "0000:0000:0000:0000:0000:ffff:" + ipv4(from: data)
        } else {
            return address
        }
    }
}

extension NetworkAddress: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.services == rhs.services && lhs.port == rhs.port && lhs.ip == rhs.ip
    }
}

extension NetworkAddress: CustomStringConvertible {
    public var description: String {
        return "[\(Self.parseIP(data: ip))]:\(port.bigEndian)\(services)"
    }
}
