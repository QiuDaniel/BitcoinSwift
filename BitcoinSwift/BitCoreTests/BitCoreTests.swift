//
//  BitCoreTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/11/25.
//

import XCTest
@testable import BitCore

class BitCoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let x1 = minimallyEncode([0x01, 0x00, 0x80])
        XCTAssertTrue(x1 == Data(0x81))
        let x2 = minimallyEncode([0xab, 0xcd, 0xef, 0x00])
        XCTAssertEqual(x2, [0xab, 0xcd, 0xef, 0x00])
        let x3 = minimallyEncode([0xab, 0xcd, 0x7f, 0x00])
        XCTAssertEqual(x3, [0xab, 0xcd, 0x7f])
        let x4 = minimallyEncode([0xab, 0xcd, 0xef, 0x42, 0x80])
        XCTAssertEqual(x4, [0xab, 0xcd, 0xef, 0xc2])
        let x5 = minimallyEncode([0xab, 0xcd, 0x7f, 0x42, 0x00])
        XCTAssertEqual(x5, [0xab, 0xcd, 0x7f, 0x42])
        let x6 = minimallyEncode([0x02, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(x6, [0x02])
        let x7 = minimallyEncode([0x80])
        XCTAssertEqual(x7, Data.empty)
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func minimallyEncode(_ value: Data) -> Data {
        guard value.count > 1 else {
            return .empty
        }
        var data = value
        let last: UInt8 = data.last!
        if last & 0x7f > 0 {
            return data
        }
        guard data[data.count - 2] & 0x80 == 0 else {
            return data
        }
        while data.count > 1 {
            let i = data.count - 1
            if data[i - 1] != 0 {
                if data[i - 1] & 0x80 != 0 {
                    data[i] = last
                } else {
                    data[i - 1] |= last
                    data.removeLast()
                }
                return data
            } else {
                data.remove(at: i - 1)
            }
        }
        return .empty
    }

}
