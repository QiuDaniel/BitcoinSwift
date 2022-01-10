//
//  PrivateKeyTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/27.
//

import XCTest
@testable import BitCore
import CryptoKit

class PrivateKeyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRFC6979() throws {
        for vector in testVectors {
            verifyRFC6979(with: vector[0], message: vector[1], expectedK: vector[2])
        }
    }
    
    func testSignature() {
        for vector in testVectors {
            verifySign(with: vector[0], message: vector[1], expectedRS: (vector[3], vector[4]))
        }
    }
    
    func testWIF1() {
        let wif = "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v"
        let prvatekey = try! PrivateKey<Secp256k1>(wif: wif)
        XCTAssertEqual(wif, prvatekey?.toWIF(isCompressed: false))
    }
    
    func testWIF2() {
        let privateKey = PrivateKey<Secp256k1>(hex: "0x1cca23de92fd1862fb5b76e5f4f50eb082165e5191e116c18ed1a6b24be6a53f", network: .BTCtestnet)
        let expected = "cNYfWuhDpbNM1JWc3c6JTrtrFVxU4AGhUKgw5f93NP2QaBqmxKkg"
        XCTAssertEqual(privateKey?.toWIF(), expected)
    }
    
    func testWIF3() {
        let privateKey = PrivateKey<Secp256k1>(hex: "0x0dba685b4511dbd3d368e5c4358a1277de9486447af7b3604a69b8d9d8b7889d")
        let expected = "5HvLFPDVgFZRK9cd4C5jcWki5Skz6fmKqi1GQJf5ZoMofid2Dty"
        XCTAssertEqual(privateKey?.toWIF(isCompressed: false), expected)
    }
    
    func testWIF4() {
        let number = BigNumber(2).power(256) - BigNumber(2).power(199)
        let privateKey = PrivateKey<Secp256k1>(secret: number)
        let expected = "L5oLkpV3aqBJ4BgssVAsax1iRa77G5CVYnv9adQ6Z87te7TyUdSC"
        XCTAssertEqual(privateKey?.toWIF(), expected)
    }
    
    func testWIF5() {
        let number = BigNumber(2).power(256) - BigNumber(2).power(201)
        let privateKey = PrivateKey<Secp256k1>(secret: number, network: .BTCtestnet)
        let expected = "93XfLeifX7Jx7n7ELGMAf1SUR6f9kgQs8Xke8WStMwUtrDucMzn"
        XCTAssertEqual(privateKey?.toWIF(isCompressed: false), expected)
    }
    
    func testSign() {
        let point = Point<Secp256k1>(x: BigNumber(hex: "0x887387e452b8eacc4acfde10d9aaf7f6d9a0f975aabb10d006e4da568744d06c")!, y: BigNumber(hex: "0x61de6d95231cd89026e286df3b6ae4a894a3378e393e93a0f45b666329a0ae34")!)
        let signature = Signature<Secp256k1>(r: BigNumber(hex:"0xac8d1c87e51d0d441be8b3dd5b05c8795b48875dffe00b7ffcfac23010d3a395")!, s: BigNumber(hex: "0x68342ceff8935ededd102dd876ffd6ba72d6a427a3edb13d26eb0781cb423c4")!)!
        XCTAssertTrue(point.verify(Message(hashedHex: "0xec208baa0fc1c19f708a9ca96fdeff3ac3f230bb4a7ba4aede4942ad003c0f60"), signature: signature))
        
        let signature1 = Signature<Secp256k1>(r: BigNumber(hex:"0xeff69ef2b1bd93a66ed5219add4fb51e11a840f404876325a1e8ffe0529a2c")!, s: BigNumber(hex: "0xc7207fee197d27c618aea621406f6bf5ef6fca38681d82b2f06fddbdce6feab6")!)!
        XCTAssertTrue(point.verify(Message(hashedHex: "0x7c076ff316692a3d7eb3c3bb0f8b1488cf72e1afcd929e29307032997a838a3d"), signature: signature1))
        
        let point1 = Point<Secp256k1>(x: BigNumber(hex: "0x04519fac3d910ca7e7138f7013706f619fa8f033e6ec6e09370ea38cee6a7574")!, y: BigNumber(hex: "0x82b51eab8c27c66e26c858a079bcdf4f1ada34cec420cafc7eac1a42216fb6c4")!)
        let signature2 = Signature<Secp256k1>(r: BigNumber(hex:"0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6")!, s: BigNumber(hex: "0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec")!)!
        XCTAssertTrue(point1.verify(Message(hashedHex: "0xbc62d4b80d9e36da29c16c5d4d9f11731f36052c72401a76c23c0fb5a9b74423"), signature: signature2))
    }
    
    func testPointOnCurve() {
        let pont = Point<Secp256k1>(x: BigNumber(hex: "0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")!, y: BigNumber(hex: "0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8")!)
        XCTAssertTrue(pont.isOnCurve)
    }
    
    private func verifyRFC6979(with key: String, message: String, expectedK: String) {
        let privateKey = PrivateKey<Secp256k1>(hex: key)!
        let mes = Message(unhashedString: message, function: SHA256())!
        let k = privateKey.deterministicRFC6979(message: mes, function: SHA256())
        XCTAssertEqual(k.hexString(uppercased: false), expectedK)
    }
    
    private func verifySign(with key: String, message: String, expectedRS:(String, String)) {
        let privateKey = PrivateKey<Secp256k1>(hex: key)!
        let mes = Message(unhashedString: message, function: SHA256())!
        let signature = privateKey.sign(message: mes, function: SHA256())!
        XCTAssertEqual(signature, Signature(r: BigNumber(hex: expectedRS.0)!, s: BigNumber(hex: expectedRS.1)!))
    }

}

private let testVectors = [
//    ["c9afa9d845ba75166b5c215767b1d6934e50c3db36e89b127b8a622b120f6721", "sample", "a6e3c57dd01abe90086538398355dd4c3b17aa873382b0f24d6129493d8aad60", "efd48b2aacb6a8fd1140dd9cd45e81d69d2c877b56aaf991c34d0ea84eaf3716", "f7cb1c942d657c41d436c7a1b6e29f65f3e900dbb9aff4064dc4ab2f843acda8"],
//    ["c9afa9d845ba75166b5c215767b1d6934e50c3db36e89b127b8a622b120f6721", "test", "d16b6ae827f17175e040871a1c7ec3500192c4c92677336ec2537acaee0008e0", "f1abb023518351cd71d881567b1ea663ed3efcf6c5132b354f28d3b0b7d38367", "19f4113742a2b14bd25926b49c649155f267e60d3814b4c0cc84250e46f0083"],
    ["CCA9FBCC1B41E5A95D369EAA6DDCFF73B61A4EFAA279CFC6567E8DAA39CBAF50", "sample", "2df40ca70e639d89528a6b670d9d48d9165fdc0febc0974056bdce192b8e16a3", "af340daf02cc15c8d5d08d7735dfe6b98a474ed373bdb5fbecf7571be52b3842", "5009fb27f37034a9b24b707b7c6b79ca23ddef9e25f7282e8a797efe53a8f124"],
    ["0000000000000000000000000000000000000000000000000000000000000001", "Satoshi Nakamoto", "8f8a276c19f4149656b280621e358cce24f5f52542772691ee69063b74f15d15", "934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d8", "2442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5"],
    ["fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140", "Satoshi Nakamoto", "33a19b60e25fb6f4435af53a3d42d493644827367e6453928554f43e49aa6f90", "fd567d121db66e382991534ada77a6bd3106f0a1098c231e47993447cd6af2d0", "6b39cd0eb1bc8603e159ef5c20a5c8ad685a45b06ce9bebed3f153d10d93bed5"],
    ["f8b8af8ce3c7cca5e300d33939540c10d45ce001b8f252bfbc57ba0342904181", "Alan Turing", "525a82b70e67874398067543fd84c83d30c175fdc45fdeee082fe13b1d7cfdf1", "7063ae83e7f62bbb171798131b4a0564b956930092b33b07b395615d9ec7e15c", "58dfcc1e00a35e1572f366ffe34ba0fc47db1e7189759b9fb233c5b05ab388ea"],
    ["0000000000000000000000000000000000000000000000000000000000000001", "All those moments will be lost in time, like tears in rain. Time to die...", "38aa22d72376b4dbc472e06c3ba403ee0a394da63fc58d88686c611aba98d6b3", "8600dbd41e348fe5c9465ab92d23e3db8b98b873beecd930736488696438cb6b", "547fe64427496db33bf66019dacbf0039c04199abb0122918601db38a72cfc21"],
    ["e91671c46231f833a6406ccbea0e3e392c76c167bac1cb013f6f1013980455c2", "There is a computer disease that anybody who works with computers knows about. It's a very serious disease and it interferes completely with the work. The trouble with computers is that you 'play' with them!", "1f4b84c23a86a221d233f2521be018d9318639d5b8bbd6374a8a59232d16ad3d", "b552edd27580141f3b2a5463048cb7cd3e047b97c9f98076c32dbdf85a68718b", "279fa72dd19bfae05577e06c7c0c1900c371fcd5893f7e1d56a37d30174671f6"],
]
