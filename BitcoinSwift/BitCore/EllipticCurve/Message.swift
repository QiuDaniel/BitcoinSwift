//
//  Message.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/28.
//

import Foundation
import CryptoKit

public struct Message: CustomStringConvertible {
    
    private let raw: Data
    
    ///  The data ought to be hashed before signed.
    public init(raw: Data) {
        self.raw = raw
    }
    
    public init(hashedHex: String) {
        let data = Data(hex: hashedHex)
        self.init(raw: data)
    }
}

// MARK: - Convenience Initializers

public extension Message {
    init<H>(unhashedData: Data, function: H) where H: HashFunction {
        var hasher = function
        hasher.update(data: unhashedData)
        self.init(raw: Data(hasher.finalize()))
    }
    
    init?<H>(unhashedString: String, encoding: String.Encoding = .default, function: H) where H: HashFunction {
        guard let unhashedData = unhashedString.data(using: encoding) else {
            return nil
        }
        self.init(unhashedData: unhashedData, function: function)
    }
}

extension Message: Equatable {}

public extension Message {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.raw == rhs.raw
    }
}

public extension Message {
    var hex: String {
        return raw.toHexString()
    }
    
    var description: String {
        return hex
    }
}

extension Message: BinaryConvertible {
    public var data: Data {
        return raw
    }
}
