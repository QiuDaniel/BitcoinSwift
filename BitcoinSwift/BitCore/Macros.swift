//
//  Macros.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/23.
//

import Foundation

internal func incorrectImplementation(_ reason: String?, _ file: String = #file, _ line: Int = #line) -> Never {
    let message: String
    let base = "Incorrect implementation, file: \(file), line: \(line)"
    if let reason = reason {
        message = "\(base), \(reason)"
    } else {
        message = base
    }
    fatalError(message)
}
