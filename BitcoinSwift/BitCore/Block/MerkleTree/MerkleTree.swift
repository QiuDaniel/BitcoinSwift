//
//  MerkleTree.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import Foundation
import BigInt

class MerkleTree {
    
    enum MerkleTreeError: Error {
        case invalidNumberOfHashes
        case invalidNumberOfFlags
    }
    
    struct MerkleTreeNode {
        var hash: Data?
        
        init(_ hash: Data) {
            self.hash = hash
        }
    }
    
    let total: BigUInt
    let maxDepth: BigUInt
    var nodes: [[MerkleTreeNode]]
    var currentDepth: BigNumber
    var currentIndex: BigNumber
    
    
    /// build a empty tree
    /// - Parameter total: node numbers
    init(_ total: BigUInt) {
        self.total = total
        self.maxDepth = ceilLog2(total)
        self.nodes = [[MerkleTreeNode]]()
        self.currentDepth = 0
        self.currentIndex = 0
        for depth in 0..<(maxDepth + 1) {
            let itemNum = ceil(Double(total) / Double(BigUInt(2).power(Int(maxDepth - depth))))
            let levelHashes = [MerkleTreeNode](repeating: MerkleTreeNode(.empty), count: Int(itemNum))
            self.nodes.append(levelHashes)
        }
    }
    
    func populateTree(flagBits: [UInt], hashes: [Data]) throws {
        var tmpHashes = hashes
        var tmpBits = flagBits
        repeat {
            if self.isLeaf {
                tmpBits = Array(tmpBits.dropFirst(1))
                let hash = tmpHashes.removeFirst()
                currentNode = MerkleTreeNode(hash)
                up()
            } else {
                let leftHash = leftNode.hash
                if leftHash == nil || leftHash == .empty {
                    if tmpBits.removeFirst() == 0 {
                        currentNode = MerkleTreeNode(tmpHashes.removeFirst())
                        up()
                    } else {
                        left()
                    }
                } else if rightExists {
                    let rightHash = rightNode.hash
                    if rightHash == nil || rightHash == .empty {
                        right()
                    } else {
                        currentNode = merkleParent(leftNode, rightNode)
                        up()
                    }
                } else {
                    currentNode = merkleParent(leftNode, leftNode)
                    up()
                }
            }
        } while self.root.hash == nil || self.root.hash == .empty
        if tmpHashes.count != 0 {
            throw MerkleTreeError.invalidNumberOfHashes
        }
        for flag in tmpBits {
            if flag != 0 {
                throw MerkleTreeError.invalidNumberOfFlags
            }
        }
    }
    
    static func merkleRoot(_ hashes: [Data]) throws -> Data {
        var currentHashes = hashes
        repeat {
            currentHashes = try merkleParentLevel(currentHashes)
        } while currentHashes.count > 1
        return currentHashes[0]
    }
}

extension MerkleTree: CustomStringConvertible {
    
    var description: String {
        var result = [String]()
        for (depth, level) in self.nodes.enumerated() {
            var items = [String]()
            var short = ""
            for (index, h) in level.enumerated() {
                if h.hash == nil || h.hash == .empty {
                    short = "None"
                } else {
                    short = "\(h.hash!.toHexString().prefix(8))"
                }
                if depth == self.currentDepth && index == self.currentIndex {
                    items.append(String(format: "*{%@}*", String(short.dropLast(2))))
                } else {
                    items.append(short)
                }
            }
            result.append(items.joined(separator: ", "))
        }
        return "\n" + result.joined(separator: "\n")
    }
    
}

private extension MerkleTree {
    static func merkleParentLevel(_ hashes:[Data]) throws -> [Data] {
        if hashes.count <= 1 {
            throw MerkleTreeError.invalidNumberOfHashes
        }
        var tmpHashes = hashes
        if tmpHashes.count % 2 == 1 {
            tmpHashes.append(hashes.last!)
        }
        var parentLevel = [Data]()
        for i in stride(from: 0, to: tmpHashes.count, by: 2) {
            let parentHash = Crypto.hash256(tmpHashes[i] + tmpHashes[i + 1])
            parentLevel.append(parentHash)
        }
        return parentLevel
    }
}
