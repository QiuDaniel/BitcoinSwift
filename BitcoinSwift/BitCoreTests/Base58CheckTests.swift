//
//  Base58CheckTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import XCTest
@testable import BitCore

class Base58CheckTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBase58CheckDecode() throws {
        let addr = "mnrVtF8DWjMu839VW3rBfgYaAfKk8983Xf"
        let h160 = Base58Check.decode(addr)?.dropFirst().hex
        let want = "507b27411ccf7f16f10297de6cef3f291623eddf"
        XCTAssertEqual(h160, want)
    }
    
    func testBase58CheckEncode() {
        let hex = "507b27411ccf7f16f10297de6cef3f291623eddf"
        let got = Base58Check.encode(Data(hex: "6f") + Data(hex: hex))
        let addr = "mnrVtF8DWjMu839VW3rBfgYaAfKk8983Xf"
        XCTAssertEqual(addr, got)
    }

}
