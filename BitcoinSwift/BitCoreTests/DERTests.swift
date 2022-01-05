//
//  DERTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/27.
//

import XCTest
@testable import BitCore

class DERTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDEREncode() throws {
        let r = BigNumber(hex: "0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6")!
        let s = BigNumber(hex: "0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec")!
        
        let hex = DER.encode(r: r, s: s)
        XCTAssertEqual(hex, "3045022037206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c60221008ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec")
    }
    
    func testDERDecode() {
        let result = DER.decode(data: Data(hex: "3045022037206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c60221008ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec"))
        let r = BigNumber(hex: "0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6")!
        let s = BigNumber(hex: "0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec")!
        XCTAssertEqual(r, result?.r)
        XCTAssertEqual(s, result?.s)
    }

}
