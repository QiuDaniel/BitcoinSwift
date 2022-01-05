//
//  PublicKeyTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import XCTest
@testable import BitCore

class PublicKeyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddress() {
        let number = BigNumber(888).power(3)
        let privateKey = PrivateKey<Secp256k1>(secret: number)!
        let pubKey = PublicKey(privateKey: privateKey)
        let mainnetAddress = "148dY81A9BmdpMhvYEVznrM45kWN32vSCN"
        XCTAssertEqual(pubKey.toBitcoinAddress().legacy, mainnetAddress)
    }
    
    func testAddress1() {
        let number = BigNumber(888).power(3)
        let privateKey = PrivateKey<Secp256k1>(secret: number, network: .BTCtestnet)!
        let pubKey = PublicKey(privateKey: privateKey)
        let testnetAddress = "mieaqB68xDCtbUBYFoUNcmZNwk74xcBfTP"
        XCTAssertEqual(pubKey.toBitcoinAddress().legacy, testnetAddress)
    }
    
    func testAddress2() {
        let number = BigNumber(321)
        let privateKey = PrivateKey<Secp256k1>(secret: number)!
        let pubKey = PublicKey(privateKey: privateKey, isCompressed: false)
        let mainnetAddress = "1S6g2xBJSED7Qr9CYZib5f4PYVhHZiVfj"
        XCTAssertEqual(pubKey.toBitcoinAddress().legacy, mainnetAddress)
    }
    
    func testAddress3() {
        let number = BigNumber(321)
        let privateKey = PrivateKey<Secp256k1>(secret: number, network: .BTCtestnet)!
        let pubKey = PublicKey(privateKey: privateKey, isCompressed: false)
        let testnetAddress = "mfx3y63A7TfTtXKkv7Y6QzsPFY6QCBCXiP"
        XCTAssertEqual(pubKey.toBitcoinAddress().legacy, testnetAddress)
    }
    
    func testAddress4() {
        let number = BigNumber(4242424242)
        let privateKey = PrivateKey<Secp256k1>(secret: number)!
        let pubKey = PublicKey(privateKey: privateKey, isCompressed: false)
        let mainnetAddress = "1226JSptcStqn4Yq9aAmNXdwdc2ixuH9nb"
        XCTAssertEqual(pubKey.toBitcoinAddress().legacy, mainnetAddress)
    }
    
    func testAddress5() {
        let number = BigNumber(4242424242)
        let privateKey = PrivateKey<Secp256k1>(secret: number, network: .BTCtestnet)!
        let pubKey = PublicKey(privateKey: privateKey, isCompressed: false)
        let testnetAddress = "mgY3bVusRUL6ZB2Ss999CSrGVbdRwVpM8s"
        XCTAssertEqual(pubKey.toBitcoinAddress().legacy, testnetAddress)
    }

}
