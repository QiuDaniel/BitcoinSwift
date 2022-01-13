//
//  BlockTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/4.
//

import XCTest
@testable import BitCore
@testable import BigInt

class BlockTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBlockParse() throws {
        let blockHex = "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d"
        let block = Block.parse(ByteStream(Data(hex: blockHex)))
        XCTAssertEqual(block.version, 0x20000002)
        XCTAssertEqual(block.prevBlock, Data(hex: "000000000000000000fd0c220a0a8c3bc5a7b487e8c8de0dfa2373b12894c38e"))
        XCTAssertEqual(block.merkleRoot, Data(hex: "be258bfd38db61f957315c3f9e9c5e15216857398d50402d5089a8e0fc50075b"))
        XCTAssertEqual(block.timestamp, 0x59a7771e)
        XCTAssertEqual(block.bits.data, Data(hex: "e93c0118"))
        XCTAssertEqual(block.nonce.data, Data(hex: "a4ffd71d"))
    }
    
    func testBlockSerialize() {
        let raw = Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d")
        let block = Block.parse(ByteStream(raw))
        XCTAssertEqual(block.serialize(), raw)
    }
    
    func testBlockHash() {
        let raw = Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d")
        let block = Block.parse(ByteStream(raw))
        XCTAssertEqual(block.blockHash, Data(hex: "0000000000000000007e9e4c586439b0cdbe13b1370bdd9435d76a644d047523"))
    }
    
    func testBIP9() {
        let raw1 = Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d")
        let block1 = Block.parse(ByteStream(raw1))
        XCTAssertTrue(block1.isBIP9)
        let raw2 = Data(hex: "0400000039fa821848781f027a2e6dfabbf6bda920d9ae61b63400030000000000000000ecae536a304042e3154be0e3e9a8220e5568c3433a9ab49ac4cbb74f8df8e8b0cc2acf569fb9061806652c27")
        let block2 = Block.parse(ByteStream(raw2))
        XCTAssertFalse(block2.isBIP9)
    }
    
    func testBIP91() {
        let raw1 = Data(hex: "1200002028856ec5bca29cf76980d368b0a163a0bb81fc192951270100000000000000003288f32a2831833c31a25401c52093eb545d28157e200a64b21b3ae8f21c507401877b5935470118144dbfd1")
        let block1 = Block.parse(ByteStream(raw1))
        XCTAssertTrue(block1.isBIP91)
        let raw2 = Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d")
        let block2 = Block.parse(ByteStream(raw2))
        XCTAssertFalse(block2.isBIP91)
    }
    
    func testBIP141() {
        let raw1 = Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d")
        let block1 = Block.parse(ByteStream(raw1))
        XCTAssertTrue(block1.isBIP141)
        let raw2 = Data(hex: "0000002066f09203c1cf5ef1531f24ed21b1915ae9abeb691f0d2e0100000000000000003de0976428ce56125351bae62c5b8b8c79d8297c702ea05d60feabb4ed188b59c36fa759e93c0118b74b2618")
        let block2 = Block.parse(ByteStream(raw2))
        XCTAssertFalse(block2.isBIP141)
    }
    
    func testTarget() {
        let stream =  ByteStream(Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d"))
        let block = Block.parse(stream)
        XCTAssertEqual(block.target, BigUInt(hex: "0x13ce9000000000000000000000000000000000000000000"))
    }
    
    func testDifficulty() {
        let stream = ByteStream(Data(hex: "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d"))
        let block = Block.parse(stream)
        XCTAssertEqual(block.difficulty, BigUInt(888171856257))
    }
    
    func testCheckPoW() {
        let stream = ByteStream(Data(hex: "04000000fbedbbf0cfdaf278c094f187f2eb987c86a199da22bbb20400000000000000007b7697b29129648fa08b4bcd13c9d5e60abb973a1efac9c8d573c71c807c56c3d6213557faa80518c3737ec1"))
        let block = Block.parse(stream)
        XCTAssertTrue(block.checkPoW())
        let stream1 = ByteStream(Data(hex: "04000000fbedbbf0cfdaf278c094f187f2eb987c86a199da22bbb20400000000000000007b7697b29129648fa08b4bcd13c9d5e60abb973a1efac9c8d573c71c807c56c3d6213557faa80518c3737ec0"))
        let block1 = Block.parse(stream1)
        XCTAssertFalse(block1.checkPoW())
    }
    
    func testCalculateNewBits() {
        let preBits = Data(hex: "54d80118").to(UInt32.self)
        let newBits = Block.calculateNewBits(prevBits: preBits, timeDifferential: 302400)
        XCTAssertEqual(newBits, Data(hex: "00157617").to(UInt32.self))
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
