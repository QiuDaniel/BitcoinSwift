//
//  Crypto.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/23.
//

import Foundation
import CryptoKit

public struct Crypto {}

public extension Crypto {
    
    static func hash<H>(_ value: BinaryConvertible, function: H) -> Data where H: HashFunction {
        var hasher = function
        hasher.update(data: value.data)
        return Data(hasher.finalize())
    }
    
    static func hmac<H>(key: BinaryConvertible, value: BinaryConvertible, function: H) -> Data where H: HashFunction {
        var hmac = HMAC<H>(key: SymmetricKey(data: key.data))
        hmac.update(data: value.data)
        return Data(hmac.finalize())
    }
}

public extension Crypto {
    
    /// ripemd160
    /// - Parameter value: message need to be hashed
    /// - Returns: hashed value
    static func ripemd160(_ value: Data) -> Data {
        return RIPEMD160.hash(message: value)
    }
    
    
    /// sha256
    /// - Parameter value: message need to be hashed
    /// - Returns: hashed value
    static func sha256(_ value: Data) -> Data {
        return hash(value, function: SHA256())
    }
    
    
    /// two rounds of sha256
    /// - Parameter value: message need to be hashed
    /// - Returns: hashed value
    static func hash256(_ value: Data) -> Data {
        return sha256(sha256(value))
    }
    
    /// sha256 followed by ripemd160
    /// - Parameter value: message need to be hashed
    /// - Returns: hashed value
    static func hash160(_ value: Data) -> Data {
        return ripemd160(sha256(value))
    }
}

extension Data {
    
    func sha256() -> Self {
        bytes.sha256()
    }
    
}


extension Array where Element == UInt8 {
    
    func sha256() -> Data {
        var sha = SHA256()
        sha.update(data: self)
        return Data(sha.finalize())
    }
    
}
