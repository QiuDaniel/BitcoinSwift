//
//  SecureRandom.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/22.
//

import Foundation
import Security

public func securelyGenerateBytes(count: Int) throws -> Data {
    var randomBytes = [UInt8](repeating: 0, count: count)
    let statusRaw = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes) as OSStatus
    let status = Status(status: statusRaw)
    guard status == .success else { throw status }
    return Data(randomBytes)
}
