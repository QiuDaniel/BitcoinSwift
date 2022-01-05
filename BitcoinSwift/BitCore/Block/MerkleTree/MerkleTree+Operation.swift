//
//  MerkleTree+Operation.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import Foundation

extension MerkleTree {
    
    var root: MerkleTreeNode {
        return self.nodes[0][0]
    }
    
    var currentNode: MerkleTreeNode {
        set {
            nodes[Int(currentDepth)][Int(currentIndex)] = newValue
        }
        
        get {
            return nodes[Int(currentDepth)][Int(currentIndex)]
        }
    }
    
    var leftNode: MerkleTreeNode {
        return nodes[Int(currentDepth) + 1][Int(currentIndex) * 2]
    }
    
    var rightNode: MerkleTreeNode {
        return nodes[Int(currentDepth) + 1][Int(currentIndex) * 2 + 1]
    }
    
    var isLeaf: Bool {
        return currentDepth == maxDepth
    }
    
    var rightExists: Bool {
        return nodes[Int(currentDepth) + 1].count > Int(currentIndex) * 2 + 1
    }
    
    func up() {
        self.currentDepth -= 1
        self.currentIndex /= 2
    }
    
    func left() {
        self.currentDepth += 1
        self.currentIndex *= 2
    }
    
    func right() {
        self.currentDepth += 1
        self.currentIndex = self.currentIndex * 2 + 1
    }
    
    func merkleParent(_ leftNode: MerkleTreeNode, _ rightNode: MerkleTreeNode) -> MerkleTreeNode {
        let parentHash = Crypto.hash256(leftNode.hash! + rightNode.hash!)
        return MerkleTreeNode(parentHash)
    }
    
}

