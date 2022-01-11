//
//  PrivateKey.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/27.
//

import Foundation
import CryptoKit

public struct PrivateKey<T>: Equatable where T: EllipticCurve {
    
    public let secret: BigNumber
    public let network: Network
    
    public init(network: Network = .BTCmainnet) {
        let byteCount = (T.N - 1).bit256Data().byteCount
        var key: PrivateKey!
        repeat {
            guard let randomBytes = try? securelyGenerateBytes(count: byteCount) else {
                continue
            }
            let randomNumber = BigNumber(data: Data(randomBytes))
            key = PrivateKey(secret: randomNumber, network: network)
        } while key == nil
        self = key
    }
    
    public init?(secret: BigNumber, network: Network = .BTCmainnet) {
        guard case 1..<T.N = secret else {
            return nil
        }
        self.network = network
        self.secret = secret
    }
    
    public init?(hex: String, network: Network = .BTCmainnet) {
        guard let secret = BigNumber(hex: hex) else {
            return nil
        }
        self.init(secret: secret, network: network)
    }
    
    public init?(data: Data, network: Network = .BTCmainnet) {
        let secret = BigNumber(data: data)
        self.init(secret: secret, network: network)
    }
    
    public init?(wif: String) throws {
        // wif格式有前缀及压缩格式需增加后缀
        guard var payload = Base58Check.decode(wif), (payload.count == 33 || payload.count == 34) else {
            throw PrivateKeyError.invalidFormat
        }
        let prefix = payload.popFirst()!
        var network: Network
        switch prefix {
        case Network.BTCmainnet.privateKey:
            network = .BTCmainnet
        case Network.BTCtestnet.privateKey:
            network = .BTCtestnet
        default:
            throw PrivateKeyError.invalidFormat
        }
        self.init(data: payload.prefix(32), network: network)
    }
    
    public func toPublickKey() -> PublicKey<T> {
        let header = data[0]
        return PublicKey(privateKey: self, isCompressed: (header == 0x02 || header == 0x03))
    }
    
    public func toWIF(isCompressed: Bool = true) -> String {
        var payload = Data([network.privateKey]) + data
        if isCompressed {
            payload.append(Data(0x01))
        }
        return Base58Check.encode(payload)
    }
    
    public func sign<H>(message: Message, function: H) -> Signature<T>? where H: HashFunction {
        let z: NumberConvertible = message
        var r: BigNumber = 0
        var s: BigNumber = 0
        repeat {
            var k = deterministicRFC6979(message: message, function: function)
            k = T.modN{ k } // make sure k belongs to [0, n - 1]
            let point = T.G * k
            r = T.modN { point.x }
            guard !r.isZero else {
                continue
            }
            let kInverse = T.divideN(1, denominator: k)
            s = T.modN { (z + r * secret) * kInverse }
        } while s.isZero
        return Signature<T>(r: r, s: s)
    }
    
    public func sign(message: Message) -> Signature<T>? {
        return sign(message: message, function: SHA256())
    }
    
    
    /// https://tools.ietf.org/html/rfc6979#section-3.2
    /// - Parameter message: Message
    func deterministicRFC6979<H>(message: Message, function: H) -> BigNumber where H: HashFunction {
        let byteCount = message.byteCount
        let qlen = T.N.magnitude.bitWidth
        
        var k: BinaryConvertible = [UInt8](repeating: 0x00, count: byteCount)
        var v: BinaryConvertible = [UInt8](repeating: 0x01, count: byteCount)
        
        let sBytes = self.secret.bit256Data().bytes
        let messageBytes = message.data.bytes
        
        func HMAC_K(_ data: BinaryConvertible) -> Data {
            return Crypto.hmac(key: k, value: data, function: function)
        }
        
        k = HMAC_K(v + 0x00 + sBytes + messageBytes)
        v = HMAC_K(v)
        k = HMAC_K(v + 0x01 + sBytes + messageBytes)
        v = HMAC_K(v)
        
        var result: BigNumber = 0
        
        /// - https://datatracker.ietf.org/doc/html/rfc6979#page-73
        func bits2Int(_ data: BinaryConvertible) -> BigNumber {
            var x = BigNumber(data)
            let l = x.magnitude.bitWidth
            if l > qlen {
                x >>= (l - qlen)
            }
            return x
        }
        
        var t: BinaryConvertible
        repeat {
            t = []
            while t.byteCount < T.N.byteCount {
                v = HMAC_K(v)
                t = t + v
            }
                        
            result = bits2Int(t)
            if result >= 1 && result < T.N {
                break
            }
            k = HMAC_K(v + 0x00)
            v = HMAC_K(v)
        } while true
    
        return result
    }
}

public extension PrivateKey {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.secret == rhs.secret && lhs.network.coinType == rhs.network.coinType
    }
}

extension PrivateKey: BinaryConvertible {
    
    public var data: Data {
        return secret.bit256Data()
    }
    
    public var hex: String {
        return secret.hexStringLength64(uppercased: false)
    }
}

public enum PrivateKeyError: Error {
    case invalidFormat
}

