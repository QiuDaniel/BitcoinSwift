//
//  String.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/22.
//
// https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
    
    subscript(_ i: Int) -> String {
        return self[i..<(i + 1)]
    }
}

public extension String.Encoding {
    static var `default`: String.Encoding {
        return .ascii
    }
}
