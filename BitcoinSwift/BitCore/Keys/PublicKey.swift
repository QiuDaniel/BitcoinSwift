//
//  PublicKey.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/28.
//

import Foundation

public struct PublicKey<Curve: EllipticCurve> {
    
    public typealias ECCPoint = Point<Curve>
    public let point: ECCPoint
    public let isCompressed: Bool
    public let data: Data
    public let network: Network
    
    public var pubkeyHash: Data {
        return Crypto.hash160(data)
    }
    
    public init(point: ECCPoint, isCompressed: Bool = true, network: Network = .BTCmainnet) {
        self.point = point
        self.isCompressed = isCompressed
        self.network = network
        let x = point.x
        let y = point.y
        let xData = x.bit256Data()
        let yData = y.bit256Data()
        let uncompressedPrefix = Data(hex:"0x04")
        let compressedPrefix = Data(hex: y.isEven ? "0x02" : "0x03")
        let uncompressed = [uncompressedPrefix, xData, yData]
        let compressed = [compressedPrefix, xData]
        if isCompressed {
            self.data = compressed.reduce(.empty, +)
        } else {
            self.data = uncompressed.reduce(.empty, +)
        }
    }
    
    public init(privateKey: PrivateKey<Curve>, isCompressed: Bool = true) {
        let point = Curve.G * privateKey.secret
        self.init(point: point, isCompressed: isCompressed, network: privateKey.network)
    }
    
    public init(bytes data: Data, network: Network = .BTCmainnet) throws {
        self.data = data
        self.network = network
        let header = data[0]
        self.isCompressed = (header == 0x02 || header == 0x03)
        self.point = try Point(data: data)
    }
}

extension PublicKey: Equatable {}

public extension PublicKey {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.point == rhs.point
    }
}

/**
extension PublicKey {
    func computePublickeyData() -> Data {
        let x = point.x
        let y = point.y
        let xData = x.bit256Data()
        let yData = y.bit256Data()
        let uncompressedPrefix = Data(hex:"0x04")
        let compressedPrefix = Data(hex: y.isEven ? "0x02" : "0x03")
        let uncompressed = [uncompressedPrefix, xData, yData]
        let compressed = [compressedPrefix, xData]
        if isCompressed {
            return compressed.reduce(.empty, +)
        }
        return uncompressed.reduce(.empty, +)
    }
}
 */
