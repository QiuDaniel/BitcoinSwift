//
//  MathTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import XCTest
@testable import BitCore
@testable import BigInt

class MathTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDivide() throws {
        XCTAssertEqual(divide(2, by: 7, mod: 19), 3)
        XCTAssertEqual(divide(7, by: 5, mod: 19), 9)
        XCTAssertEqual(divide(3, by: 24, mod: 31), 4)
        XCTAssertEqual(divide(1, by: 10, mod: 13), 4)
        XCTAssertEqual(BigNumber(10).power(BigNumber(11), modulus: BigNumber(13)), 4)
        XCTAssertEqual(BigNumber(10).inverse(BigNumber(13)), 4)
        XCTAssertEqual((BigNumber(7).inverse(BigNumber(19))! * BigNumber(2)).modulus(BigNumber(19)), 3)
        XCTAssertEqual(BigNumber(10).inverse(BigNumber(13)), divide(1, by: 10, mod: 13))
        XCTAssertEqual((BigNumber(7).inverse(BigNumber(19))! * BigNumber(2)).modulus(BigNumber(19)), divide(2, by: 7, mod: 19))
    }
    
    func testCeilLog2() {
        XCTAssertEqual(ceilLog2(0), 0)
        XCTAssertEqual(ceilLog2(1), 0)
        XCTAssertEqual(ceilLog2(2), 1)
        XCTAssertEqual(ceilLog2(3), 2)
        XCTAssertEqual(ceilLog2(4), 2)
        XCTAssertEqual(ceilLog2(5), 3)
        XCTAssertEqual(ceilLog2(6), 3)
        XCTAssertEqual(ceilLog2(7), 3)
        XCTAssertEqual(ceilLog2(8), 3)
        XCTAssertEqual(ceilLog2(9), 4)
        XCTAssertEqual(ceilLog2(10), 4)
        XCTAssertEqual(ceilLog2(11), 4)
        XCTAssertEqual(ceilLog2(12), 4)
        XCTAssertEqual(ceilLog2(13), 4)
        XCTAssertEqual(ceilLog2(14), 4)
        XCTAssertEqual(ceilLog2(15), 4)
        XCTAssertEqual(ceilLog2(16), 4)
        XCTAssertEqual(ceilLog2(17), 5)
        
        XCTAssertEqual(ceilLog2(BigUInt(UInt32.max-1)), 32)
        XCTAssertEqual(ceilLog2(BigUInt(UInt32.max)), 32)
        XCTAssertEqual(ceilLog2(BigUInt(2).power(10)), 10)
    }
}
