//
//  OPCodeTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/8.
//

import XCTest
import BitCore

class OPCodeTests: XCTestCase {
    var context: ScriptExcutionContext!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context = ScriptExcutionContext(true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetWithValue() {
        assert(OPCode.parse(0x00), OPCode.OP_0)
        assert(OPCode.parse(0x4c), OPCode.OP_PUSHDATA1)
        assert(OPCode.parse(0x4f), OPCode.OP_1NEGATE)
        assert(OPCode.parse(0x51), OPCode.OP_1)
        assert(OPCode.parse(0xa9), OPCode.OP_HASH160)
        assert(OPCode.parse(0xac), OPCode.OP_CHECKSIG)
        assert(OPCode.parse(0xff), OPCode.OP_INVALIDOPCODE)
    }
    
    func testGetWithName() {
        assert(OPCode.parse("OP_0"), OPCode.OP_0)
        assert(OPCode.parse("OP_PUSHDATA1"), OPCode.OP_PUSHDATA1)
        assert(OPCode.parse("OP_1NEGATE"), OPCode.OP_1NEGATE)
        assert(OPCode.parse("OP_1"), OPCode.OP_1)
        assert(OPCode.parse("OP_HASH160"), OPCode.OP_HASH160)
        assert(OPCode.parse("OP_CHECKSIG"), OPCode.OP_CHECKSIG)
        assert(OPCode.parse("OP_INVALIDOPCODE"), OPCode.OP_INVALIDOPCODE)
    }
    
    func testCodeForSmallInteger() {
        assert(OPCode.parseSmallInteger(-1), OPCode.OP_1NEGATE)
        assert(OPCode.parseSmallInteger(0), OPCode.OP_0)
        assert(OPCode.parseSmallInteger(1), OPCode.OP_1)
        assert(OPCode.parseSmallInteger(8), OPCode.OP_8)
        assert(OPCode.parseSmallInteger(16), OPCode.OP_16)
        assert(OPCode.parseSmallInteger(17), OPCode.OP_INVALIDOPCODE)
        assert(OPCode.parseSmallInteger(Int.min), OPCode.OP_INVALIDOPCODE)
        assert(OPCode.parseSmallInteger(Int.max), OPCode.OP_INVALIDOPCODE)
    }
    
    func testOp1Negate() {
        let code = OPCode.OP_1NEGATE
        do {
            try code.excute(context)
            let num = try context.number(at: -1, pop: false)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(num, -1)
        } catch let err {
            fail(with: code, error: err)
        }
    }
    
    func testOpN() {
        let vectors: [(OpCodeType, Int32)] = [(OPCode.OP_1NEGATE, -1),
                                              (OPCode.OP_1, 1),
                                              (OPCode.OP_2, 2),
                                              (OPCode.OP_3, 3),
                                              (OPCode.OP_4, 4),
                                              (OPCode.OP_5, 5),
                                              (OPCode.OP_6, 6),
                                              (OPCode.OP_7, 7),
                                              (OPCode.OP_8, 8),
                                              (OPCode.OP_9, 9),
                                              (OPCode.OP_10, 10),
                                              (OPCode.OP_11, 11),
                                              (OPCode.OP_12, 12),
                                              (OPCode.OP_13, 13),
                                              (OPCode.OP_14, 14),
                                              (OPCode.OP_15, 15),
                                              (OPCode.OP_16, 16)]
        for (i, (code, expectedNumber)) in vectors.enumerated() {
            do {
                try code.excute(context)
                let num = try context.number(at: -1, pop: false)
                XCTAssertEqual(context.stack.count, i + 1)
                XCTAssertEqual(num, expectedNumber)
            } catch let err {
                fail(with: code, error: err)
            }
        }
    }
    
    func testOpVerify() {
        pushRandomDataOnStack(context)
        let stackCountAtFirst = context.stack.count
        let code = OPCode.OP_VERIFY
        
        // OP_CODE basic specification
        XCTAssertEqual(code.name, "OP_VERIFY")
        XCTAssertEqual(code.value, 0x69)

        // OP_VERIFY success
        do {
            context.push(true)
            XCTAssertEqual(context.stack.count, stackCountAtFirst + 1)
            try code.excute(context)
            XCTAssertEqual(context.stack.count, stackCountAtFirst, "\(code.name)(\(String(format: "%02x", code.value)) execution test.")
        } catch let error {
            fail(with: code, error: error)
        }
        
        // OP_VERIFY fail
        do {
            context.push(false)
            try code.excute(context)
            XCTFail("\(code.name)(\(code.value) execution should throw error.")
        } catch OpCodeExcutionError.error("OP_VERIFY failed.") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"OP_VERIFY failed.\"), but threw \(error)")
        }
    }
    
    func testOpDUP() {
        pushRandomDataOnStack(context)
        let stackCountAtFirst: Int = context.stack.count
        let opcode = OPCode.OP_DUP
        // OP_CODE basic specification
        XCTAssertEqual(opcode.name, "OP_DUP")
        XCTAssertEqual(opcode.value, 0x76)

        // OP_DUP success
        do {
            // Stack has more than 1 item
            XCTAssertGreaterThanOrEqual(context.stack.count, 1)
            let stackSnapShot: [Data] = context.stack
            let dataOnTop: Data = context.stack.last!
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, stackCountAtFirst + 1, "\(opcode.name)(\(String(format: "%02x", opcode.value)) test: One data should be added to stack.")
            XCTAssertEqual(context.stack.dropLast().map { Data($0) }, stackSnapShot, "\(opcode.name)(\(String(format: "%02x", opcode.value)) test: The data except the top should be the same after the execution.")
            XCTAssertEqual(context.stack.last!, dataOnTop, "\(opcode.name)(\(String(format: "%02x", opcode.value)) test: The data on top should be copied and pushed.")
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_DUP fail
        do {
            context.resetStack()
            XCTAssertEqual(context.stack.count, 0)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when stack is empty.")
        } catch OpCodeExcutionError.opcodeRequiresItemsOnStack(1) {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .opcodeRequiresItemsOnStack(1), but threw \(error)")
        }
    }
    
    func testOpCat() {
        let opcode = OPCode.OP_CAT
        
        // maxlen_x y OP_CAT -> failure
        // Concatenating any operand except an empty vector, including a single byte value (e.g. OP_1),
        // onto a maximum sized array causes failure
        do {
            try context.push(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            context.push(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when push value size limit exceeded.")
        } catch OpCodeExcutionError.error("Push value size limit exceeded") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Push value size limit exceeded\"), but threw \(error)")
        }
        
        // large_x large_y OP_CAT -> failure
        // Concatenating two operands, where the total length is greater than MAX_SCRIPT_ELEMENT_SIZE, causes failure
        do {
            context.resetStack()
            try context.push(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE / 2 + 1))
            try context.push(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE / 2))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when push value size limit exceeded.")
        } catch OpCodeExcutionError.error("Push value size limit exceeded") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Push value size limit exceeded\"), but threw \(error)")
        }
        
        // OP_0 OP_0 OP_CAT -> OP_0
        // Concatenating two empty arrays results in an empty array
        do {
            context.resetStack()
            try context.push(Data())
            try context.push(Data())
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x OP_0 OP_CAT -> x
        // Concatenating an empty array onto any operand results in the operand, including when len(x) = MAX_SCRIPT_ELEMENT_SIZE
        do {
            context.resetStack()
            try context.push(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            try context.push(Data())
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_0 x OP_CAT -> x
        // Concatenating any operand onto an empty array results in the operand, including when len(x) = MAX_SCRIPT_ELEMENT_SIZE
        do {
            context.resetStack()
            try context.push(Data())
            try context.push(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {Ox11} {0x22, 0x33} OP_CAT -> 0x112233
        // Concatenating two operands generates the correct result
        do {
            context.resetStack()
            try context.push(Data([0x11]))
            try context.push(Data([0x22, 0x33]))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data([0x11, 0x22, 0x33]))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpSize() {
        let opcode = OPCode.OP_SIZE
        // OP_SIZE succeeds
        do {
            try context.push(Data([0x01]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(try context.number(at: -1, pop: false), 1)
            XCTAssertEqual(context.data(at: -2, pop: false), Data([0x01]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_SIZE succeeds with empty array
        do {
            context.resetStack()
            try context.push(Data())
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(try context.number(at: -1, pop: false), 0)
            XCTAssertEqual(context.data(at: -2, pop: false), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_SIZE succeeds with maximum sized array case
        do {
            context.resetStack()
            try context.push(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(try context.number(at: -1, pop: false), Int32(BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.data(at: -2, pop: false), Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
        
    func testOpSplit() {
        let opcode = OPCode.OP_SPLIT
        // OP_0 0 OP_SPLIT -> OP_0 OP_0
        // Execution of OP_SPLIT on empty array results in two empty arrays.
        do {
            try context.push(Data())
            context.push(0)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data())
            XCTAssertEqual(context.data(at: -2, pop: false), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x 0 OP_SPLIT -> OP_0 x
        do {
            context.resetStack()
            try context.push(Data([0x01]))
            context.push(0)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data([0x01]))
            XCTAssertEqual(context.data(at: -2, pop: false), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x len(x) OP_SPLIT -> x OP_0
        do {
            context.resetStack()
            try context.push(Data([0x01]))
            context.push(Int32(Data([0x01]).count))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data())
            XCTAssertEqual(context.data(at: -2, pop: false), Data([0x01]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x (len(x) + 1) OP_SPLIT -> FAIL
        do {
            context.resetStack()
            try context.push(Data([0x01]))
            context.push(Int32(Data([0x01]).count + 1))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid OP_SPLIT range.")
        } catch OpCodeExcutionError.error("Invalid OP_SPLIT range") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid OP_SPLIT range\"), but threw \(error)")
        }
        
        // successful cases
        // {0x00, 0x11, 0x22} 0 OP_SPLIT -> OP_0 {0x00, 0x11, 0x22}
        do {
            context.resetStack()
            try context.push(Data([0x00, 0x11, 0x22]))
            context.push(0)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data([0x00, 0x11, 0x22]))
            XCTAssertEqual(context.data(at: -2, pop: false), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x11, 0x22} 1 OP_SPLIT -> {0x00} {0x11, 0x22}
        do {
            context.resetStack()
            try context.push(Data([0x00, 0x11, 0x22]))
            context.push(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data([0x11, 0x22]))
            XCTAssertEqual(context.data(at: -2, pop: false), Data([0x00]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x11, 0x22} 2 OP_SPLIT -> {0x00, 0x11} {0x22}
        do {
            context.resetStack()
            try context.push(Data([0x00, 0x11, 0x22]))
            context.push(2)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data([0x22]))
            XCTAssertEqual(context.data(at: -2, pop: false), Data([0x00, 0x11]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x11, 0x22} 3 OP_SPLIT -> {0x00, 0x11, 0x22} OP_0
        do {
            context.resetStack()
            try context.push(Data([0x00, 0x11, 0x22]))
            context.push(3)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1, pop: false), Data())
            XCTAssertEqual(context.data(at: -2, pop: false), Data([0x00, 0x11, 0x22]))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpBin2Num() {
        let opcode = OPCode.OP_BIN2NUM
        
        // a OP_BIN2NUM -> failure
        // when a is a byte sequence whose numeric value is too large to fit into the numeric value type, for both positive and negative values.
        do {
            try context.push(Data(0x01) + Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when push value size limit exceeded.")
        } catch OpCodeExcutionError.error("Push value size limit exceeded") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Push value size limit exceeded\"), but threw \(error)")
        }
        
        // {0x00} OP_BIN2NUM -> OP_0
        // Byte sequences, of various lengths, consisting only of zeros should produce an OP_0 (zero length array).
        do {
            context.resetStack()
            try context.push(Data(0x00))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00} OP_BIN2NUM -> 1
        // A large byte sequence, whose numeric value would fit in the numeric value type, is a valid operand
        do {
            context.resetStack()
            try context.push(Data([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(try context.number(at: -1, pop: false), 1)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, .....} OP_BIN2NUM -> 1
        // The same test as above, where the length of the input byte sequence is equal to MAX_SCRIPT_ELEMENT_SIZE.
        do {
            context.resetStack()
            var bytes = Data(repeating: 0x00, count: BTC_MAX_SCRIPT_ELEMENT_SIZE).bytes
            bytes[0] = 0x01
            try context.push(Data(bytes))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(try context.number(at: -1, pop: false), 1)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80} OP_BIN2NUM -> -1
        // Same as above, for negative values.
        do {
            context.resetStack()
            try context.push(Data([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(try context.number(at: -1, pop: false), -1)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x80} OP_BIN2NUM -> OP_0
        // Negative zero, in a byte sequence, should produce zero.
        do {
            context.resetStack()
            try context.push(Data([0x80]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false), .empty)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80} OP_BIN2NUM -> OP_0
        // Large negative zero, in a byte sequence, should produce zero
        do {
            context.resetStack()
            try context.push(Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false), .empty)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x02, 0x00, 0x00, 0x00, 0x00} OP_BIN2NUM -> 2
        // 0x0200000000 in little-endian encoding has value 2
        do {
            context.resetStack()
            try context.push(Data([0x02, 0x00, 0x00, 0x00, 0x00]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(try context.number(at: -1, pop: false), 2)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x05, 0x00, 0x80} OP_BIN2NUM -> -5
        // 0x050080 in little-endian encoding has value -5.
        do {
            context.resetStack()
            try context.push(Data([0x05, 0x00, 0x80]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(try context.number(at: -1, pop: false), -5)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
    }
    
    func testNum2Bin() {
        let opcode = OPCode.OP_NUM2BIN
        
        // 2 4 OP_NUM2BIN -> {0x02, 0x00, 0x00, 0x00}
        do {
            context.resetStack()
            context.push(2)
            context.push(4)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false), Data([0x02, 0x00, 0x00, 0x00]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // -5 4 OP_NUM2BIN -> {0x05, 0x00, 0x00, 0x80}
        do {
            context.resetStack()
            context.push(-5)
            context.push(4)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false), Data([0x05, 0x00, 0x00, 0x80]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // 256 1 OP_NUM2BIN -> failure
        do {
            context.resetStack()
            context.push(256)
            context.push(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution Trying to produce a byte sequence which is smaller than the minimum size needed to contain the numeric value..")
        } catch OpCodeExcutionError.error("The requested encoding is impossible to satisfy") {
            //success
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // 1 (MAX_SCRIPT_ELEMENT_SIZE+1) OP_NUM2BIN -> failure
        do {
            context.resetStack()
            context.push(1)
            context.push(Int32(BTC_MAX_SCRIPT_ELEMENT_SIZE + 1))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution Trying to produce an array which is too large")
        } catch OpCodeExcutionError.error("Push value size limit exceeded.") {
            //success
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpInvert() {
        let opcode = OPCode.OP_INVERT
        
        do {
            try opcode.excute(context)
        } catch OpCodeExcutionError.disabled {
            // success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.disabled, but threw \(error)")
        }
    }
    
    func testOpAnd() {
        let opcode = OPCode.OP_AND
        
        // x1 x2 OP_AND -> failure, where len(x1) != len(x2). The two operands must be the same size.
        do {
            try context.push(Data(count: 1))
            try context.push(Data(count: 3))
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid operand size.")
        } catch OpCodeExcutionError.error("Invalid OP_AND size") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid OP_AND size\"), but threw \(error)")
        }
        
        // x1 x2 OP_AND -> x1 & x2. Check valid results.
        do {
            context.resetStack()
            try context.push(Data(0b11111100))
            try context.push(Data(0b00111111))
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false), Data(0b00111100))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpOr() {
        let opcode = OPCode.OP_OR
        
        // x1 x2 OP_OR -> failure, where len(x1) != len(x2). The two operands must be the same size.
        do {
            try context.push(Data(count: 1))
            try context.push(Data(count: 3))
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid operand size.")
        } catch OpCodeExcutionError.error("Invalid OP_OR size") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid OP_OR size\"), but threw \(error)")
        }
        
        // x1 x2 OP_OR -> x1 | x2. Check valid results.
        do {
            context.resetStack()
            try context.push(Data(0b10110010))
            try context.push(Data(0b01011110))
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(0b11111110))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpXor() {
        let opcode = OPCode.OP_XOR
        
        // x1 x2 OP_XOR -> failure, where len(x1) != len(x2). The two operands must be the same size.
        do {
            try context.push(Data(count: 1))
            try context.push(Data(count: 3))
            try opcode.excute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid operand size.")
        } catch OpCodeExcutionError.error("Invalid OP_XOR size") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid OP_XOR size\"), but threw \(error)")
        }
        
        // x1 x2 OP_XOR -> x1 xor x2. Check valid results.
        do {
            context.resetStack()
            try context.push(Data(0b00010100))
            try context.push(Data(0b00000101))
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(0b00010001))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpEqualVerify() {
        let opcode = OPCode.OP_EQUALVERIFY
        // OP_EQUALVERIFY success
        do {
            context.push(1)
            context.push(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 0)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_EQUALVERIFY fail
        do {
            context.resetStack()
            context.push(1)
            context.push(3)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
        } catch OpCodeExcutionError.error("OP_EQUALVERIFY failed.") {
            // success
            XCTAssertEqual(context.stack.count, 1)
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpEqual() {
        let opcode = OPCode.OP_EQUAL
        
        // OP_EQUAL success
        do {
            context.push(1)
            context.push(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1, pop: false), true)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_EQUAL fail
        context.resetStack()
        do {
            context.push(1)
            context.push(2)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1, pop: false), false)
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpHash160() {
        let opcode = OPCode.OP_HASH160

        // OP_HASH160 success
        do {
            let data = "hello".data(using: .utf8)!
            try context.push(data)
            XCTAssertEqual(context.stack.count, 1)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1, pop: false).hex, "b6a9c8c230722b7c748331a8b450f05566dc7d0f")
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_HASH160 fail
        do {
            context.resetStack()
            XCTAssertEqual(context.stack.count, 0)
            try opcode.excute(context)
        } catch OpCodeExcutionError.opcodeRequiresItemsOnStack(1) {
            // do nothing equal success
        } catch let error {
            fail(with: opcode, error: error)
        }
    }

    func testOpCheckSigBTC() {
        let opcode = OPCode.OP_CHECKSIG

        // BTC Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        let hash = Data(hex: prevTxID)
        let index: UInt32 = 1
//        let outpoint = TransactionOutPoint(hash: hash, index: index)

        let balance: UInt64 = 169012961

        let privateKey = try! PrivateKey<Secp256k1>(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey!.toPublickKey()
        
        let subScript = Script(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(prevTx: hash, prevIndex: index, scriptSig: subScript)
        
        let banlance1: UInt64 = 50000000
        let script1 = Script(hex:"76a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ac")!
        let balance2: UInt64 = 109012961
        let script2 = Script(hex:"76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!

        let output1 = TransactionOutput(amount: banlance1, scriptPubkey: script1)
        
        let output2 = TransactionOutput(amount: balance2, scriptPubkey: script2)
        
        let unsignedTx = Transaction(version: 1, inputs: [inputForSign], outputs: [output1, output2], lockTime: 0)

        // sign
        let hashType = BTCSigHashType.ALL
        let utxoToSign = TransactionOutput(amount: balance, scriptPubkey: subScript)
        let helper = SignatureHash(hashType: hashType)
        let _txHash = helper.createSignatureHash(of: unsignedTx, for: utxoToSign, inputIndex: 0)
        guard let signature = privateKey?.sign(message: Message(raw: _txHash)) else {
            XCTFail("Failed to sign tx.")
            return
        }
        let sigData: Data = Data(hex: signature.der) + Data(hashType.uint8)
        let pubkeyData: Data = fromPublicKey.data

        // OP_CHECKSIG success
        do {
            context = ScriptExcutionContext(
                transaction: unsignedTx,
                utxoToVerify: utxoToSign,
                inputIndex: 0)
            try context.push(sigData) // sigData
            try context.push(pubkeyData) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1, pop: false), true)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG success(invalid signature)
        do {
            context = ScriptExcutionContext(
                transaction: Transaction(
                    version: 1,
                    inputs: [TransactionInput(prevTx: Data(), prevIndex: 0, scriptSig: Script(), sequence: 0)],
                    outputs: [],
                    lockTime: 0),
                utxoToVerify: utxoToSign,
                inputIndex: 0)
            try context.push(sigData) // sigData
            try context.push(pubkeyData) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1, pop: false), false)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG fail
        do {
            context = ScriptExcutionContext()
            XCTAssertEqual(context.stack.count, 0)
            try context.push("".data(using: .utf8)!) // sigData
            try context.push("".data(using: .utf8)!) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
            try opcode.excute(context)
        } catch OpCodeExcutionError.error("The transaction or the utxo to verify is not set.") {
            // do nothing equal success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.error(\"The transaction or the utxo to verify is not set.\", but threw \(error)")
        }
    }

    func testOpInvalidOpCode() {
        let opcode = OPCode.OP_INVALIDOPCODE
        XCTAssertEqual(opcode.name, "OP_INVALIDOPCODE")
        XCTAssertEqual(opcode.value, 0xff)

        do {
            try opcode.excute(context)
        } catch OpCodeExcutionError.error("OP_INVALIDOPCODE should not be executed.") {
            // success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.error(\"OP_INVALIDOPCODE should not be executed.\", but threw \(error)")
        }
    }

    private func assert(_ lhs: OpCodeType, _ rhs: OpCodeType) {
        XCTAssertEqual(lhs.name, rhs.name)
        XCTAssertEqual(lhs.value, rhs.value)
    }
    
    private func fail(with opCode: OpCodeType, error: Error) {
        XCTFail("\(opCode.name)(\(opCode.value)) execution should not fail.\nError: \(error)")
    }
    
    private func pushRandomDataOnStack(_ context: ScriptExcutionContext) {
        context.resetStack()
        let rand = arc4random() % 50 + 1
        for _ in (0..<rand) {
            let nextRand = arc4random() % 32
            switch nextRand {
            case 0...16:
                context.push(Int32(nextRand))
            default:
                let extraRand = arc4random()
                let data: Data = extraRand.data
                try! context.push(data)
            }
        }
    }
}
