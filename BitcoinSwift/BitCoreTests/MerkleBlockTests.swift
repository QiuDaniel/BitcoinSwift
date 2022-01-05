//
//  MerkleBlockTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/31.
//
import XCTest
@testable import BitCore
@testable import BigInt

class MerkleBlockTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseMerkleBlock() throws {
        let merkleBlockHex = "00000020df3b053dc46f162a9b00c7f0d5124e2676d47bbe7c5d0793a500000000000000ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4dc7c835b67d8001ac157e670bf0d00000aba412a0d1480e370173072c9562becffe87aa661c1e4a6dbc305d38ec5dc088a7cf92e6458aca7b32edae818f9c2c98c37e06bf72ae0ce80649a38655ee1e27d34d9421d940b16732f24b94023e9d572a7f9ab8023434a4feb532d2adfc8c2c2158785d1bd04eb99df2e86c54bc13e139862897217400def5d72c280222c4cbaee7261831e1550dbb8fa82853e9fe506fc5fda3f7b919d8fe74b6282f92763cef8e625f977af7c8619c32a369b832bc2d051ecd9c73c51e76370ceabd4f25097c256597fa898d404ed53425de608ac6bfe426f6e2bb457f1c554866eb69dcb8d6bf6f880e9a59b3cd053e6c7060eeacaacf4dac6697dac20e4bd3f38a2ea2543d1ab7953e3430790a9f81e1c67f5b58c825acf46bd02848384eebe9af917274cdfbb1a28a5d58a23a17977def0de10d644258d9c54f886d47d293a411cb6226103b55635"
        let merkleBlock = MerkleBlock.parse(Data(hex: merkleBlockHex))
        XCTAssertEqual(merkleBlock.version, 0x20000000)
        let merkleRootHex = "ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4"
        XCTAssertEqual(merkleBlock.merkleRoot, Data(Data(hex: merkleRootHex).reversed()))
        let prevBlockHex = "df3b053dc46f162a9b00c7f0d5124e2676d47bbe7c5d0793a500000000000000"
        XCTAssertEqual(merkleBlock.prevBlock, Data(Data(hex: prevBlockHex).reversed()))
        let timestamp = BigUInt(Data(Data(hex: "dc7c835b").reversed()))
        XCTAssertEqual(merkleBlock.timestamp, UInt32(timestamp).littleEndian)
        XCTAssertEqual(merkleBlock.bits.data, Data(hex: "67d8001a"))
        XCTAssertEqual(merkleBlock.nonce.data, Data(hex: "c157e670"))
        let total = BigUInt(Data(Data(hex: "bf0d0000").reversed()))
        XCTAssertEqual(merkleBlock.total, UInt32(total))
        let hexHashes = ["ba412a0d1480e370173072c9562becffe87aa661c1e4a6dbc305d38ec5dc088a",
                         "7cf92e6458aca7b32edae818f9c2c98c37e06bf72ae0ce80649a38655ee1e27d",
                         "34d9421d940b16732f24b94023e9d572a7f9ab8023434a4feb532d2adfc8c2c2",
                         "158785d1bd04eb99df2e86c54bc13e139862897217400def5d72c280222c4cba",
                         "ee7261831e1550dbb8fa82853e9fe506fc5fda3f7b919d8fe74b6282f92763ce",
                         "f8e625f977af7c8619c32a369b832bc2d051ecd9c73c51e76370ceabd4f25097",
                         "c256597fa898d404ed53425de608ac6bfe426f6e2bb457f1c554866eb69dcb8d",
                         "6bf6f880e9a59b3cd053e6c7060eeacaacf4dac6697dac20e4bd3f38a2ea2543",
                         "d1ab7953e3430790a9f81e1c67f5b58c825acf46bd02848384eebe9af917274c",
                         "dfbb1a28a5d58a23a17977def0de10d644258d9c54f886d47d293a411cb62261",
            ]
        let hashes = hexHashes.map { Data(Data(hex: $0).reversed()) }
        XCTAssertEqual(merkleBlock.hashes, hashes)
        let flags = Data(hex: "b55635").bytes
        XCTAssertEqual(merkleBlock.flags, flags)
    }
    
    func testValid() {
        let merkleBlockHex = "00000020df3b053dc46f162a9b00c7f0d5124e2676d47bbe7c5d0793a500000000000000ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4dc7c835b67d8001ac157e670bf0d00000aba412a0d1480e370173072c9562becffe87aa661c1e4a6dbc305d38ec5dc088a7cf92e6458aca7b32edae818f9c2c98c37e06bf72ae0ce80649a38655ee1e27d34d9421d940b16732f24b94023e9d572a7f9ab8023434a4feb532d2adfc8c2c2158785d1bd04eb99df2e86c54bc13e139862897217400def5d72c280222c4cbaee7261831e1550dbb8fa82853e9fe506fc5fda3f7b919d8fe74b6282f92763cef8e625f977af7c8619c32a369b832bc2d051ecd9c73c51e76370ceabd4f25097c256597fa898d404ed53425de608ac6bfe426f6e2bb457f1c554866eb69dcb8d6bf6f880e9a59b3cd053e6c7060eeacaacf4dac6697dac20e4bd3f38a2ea2543d1ab7953e3430790a9f81e1c67f5b58c825acf46bd02848384eebe9af917274cdfbb1a28a5d58a23a17977def0de10d644258d9c54f886d47d293a411cb6226103b55635"
        let merkleBlock = MerkleBlock.parse(Data(hex: merkleBlockHex))
        XCTAssertTrue(merkleBlock.isValid())
    }

}
