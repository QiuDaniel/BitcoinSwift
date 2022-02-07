//
//  BloomFilterTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import XCTest
import BitCore

class BloomFilterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdd() throws {
        var bf = BloomFilter(size: 10, funcs: 5, tweak: 99)
        bf.add("Hello World".data(using: .ascii)!)
        let expected = "0000000a080000000140"
        XCTAssertEqual(bf.bytes.hex, expected)
        bf.add("Goodbye!".data(using: .ascii)!)
        let expected1 = "4000600a080000010940"
        XCTAssertEqual(bf.bytes.hex, expected1)
    }
    
    func testFilterLoad() {
        var bf = BloomFilter(size: 10, funcs: 5, tweak: 99)
        bf.add("Hello World".data(using: .ascii)!)
        bf.add("Goodbye!".data(using: .ascii)!)
        let expected = "0a4000600a080000010940050000006300000001"
        XCTAssertEqual(bf.filterLoad().serialize().hex, expected)
    }
    
    func testBloomFilter() {
        do {
            var filter = BloomFilter(elements: 1, falsePositiveRate: 0.0001, randomNonce: 0)
            filter.add(Data(hex: "019f5b01d4195ecbc9398fbf3c3b1fa9bb3183301d7a1fb3bd174fcfa40a2b65"))
            XCTAssertEqual(filter.bytes.hex, "b50f")
        }
        
        do {
            var filter = BloomFilter(elements: 3, falsePositiveRate: 0.01, randomNonce: 0)
            filter.add(Data(hex: "99108ad8ed9bb6274d3980bab5a85c048f0950c8"))
            filter.add(Data(hex: "b5a2c786d9ef4658287ced5914b37a1b4aa32eee"))
            filter.add(Data(hex: "b9300670b4c5366e95b2699e8b18bc75e5f729c5"))
            let message = filter.filterLoad()
            XCTAssertEqual(message.serialize().hex, "03614e9b050000000000000001")
        }
        
        do {
            var filter = BloomFilter(elements: 3, falsePositiveRate: 0.01, randomNonce: 2147483649)
            filter.add(Data(hex: "99108ad8ed9bb6274d3980bab5a85c048f0950c8"))
            filter.add(Data(hex: "b5a2c786d9ef4658287ced5914b37a1b4aa32eee"))
            filter.add(Data(hex: "b9300670b4c5366e95b2699e8b18bc75e5f729c5"))
            let message = filter.filterLoad()
            XCTAssertEqual(message.serialize().hex, "03ce4299050000000100008001")
        }
        
        do {
            var filter = BloomFilter(elements: 4, falsePositiveRate: 0.001, randomNonce: 100)
            filter.add(Data(hex: "03cdb817b334c8e3bdc6ce3a1eae9e624cc64426eb00ef9207d2021ce6d9253a2a"))
            filter.add(Data(hex: "a9a917faa1751b127c55e7e19f59f2e57627e908"))
            filter.add(Data(hex: "02784addc6ceed8bbbee10829194ce17c99a6a7029b3a9e078b6f849aa91c937b5"))
            filter.add(Data(hex: "7a501a08279ec396e06c88b3e9013f31c0d4ca76"))

            let message = filter.filterLoad()
            XCTAssertEqual(message.serialize().hex, "07cfe07884ebc3ac090000006400000001")
        }
    }
}
