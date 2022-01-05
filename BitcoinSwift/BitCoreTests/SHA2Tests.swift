//
//  SHA2Tests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/24.
//

import XCTest
@testable import BitCore

class SHA2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSha256() throws {
        // https://en.bitcoin.it/wiki/Test_Cases
        let message = "hello"
        let sha256Data = message.bytes.sha256()
        let sha256Hex = sha256Data.toHexString()
        XCTAssertEqual(sha256Hex, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        
        let sha256Data2 = Crypto.sha256(message.data)
        let sha256Hex2 = sha256Data2.toHexString()
        XCTAssertEqual(sha256Hex2, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
    
    func testCryptoHash256() {
        let message = "hello"
        let sha256Data = message.bytes.sha256()
        let sha256sha256Data = Crypto.hash256(message.data)
        let sha256sha256Hex = sha256sha256Data.toHexString()
        XCTAssertEqual(sha256sha256Hex, "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50")
        let sha256sha256Hex2 = sha256Data.sha256().toHexString()
        XCTAssertEqual(sha256sha256Hex2, "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50")
    }
    
    func testSha256ZeroStringConvert2Data() {
        [
            "": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "00": "6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d",
            "0000000000000000000000000000000000000000000000000000000000000000": "66687aadf862bd776c8fc18b8e9f8e20089714856ee233b3902a591d0d5f2925"
            ].forEach {
                XCTAssertEqual(sha256ConvertToData($0), $1)

        }
    }
    
    private func sha256ConvertToData(_ hexString: String) -> String {
        let data = Data(hex: hexString)
        let digest = Crypto.sha256(data)
        return digest.toHexString()
    }

}
