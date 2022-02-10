//
//  PeerGroup.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import Foundation

public protocol PeerGroupDelegate: AnyObject {
    func peerGroupDidStart(_ group: PeerGroup)
    func peerGroupDidStop(_ group: PeerGroup)
    func peerGroupDidReceiveTransaction(_ group: PeerGroup)
}

extension PeerGroupDelegate {
    func peerGroupDidStart(_ group: PeerGroup) {}
    func peerGroupDidStop(_ group: PeerGroup) {}
    func peerGroupDidReceiveTransaction(_ group: PeerGroup) {}
}

public class PeerGroup {
    public let chain: BlockChain
    public let maxConnections: Int
    
    public weak var delegate: PeerGroupDelegate?
    
    var peers = [String: Peer]()
    
    private var filters = [Data]()
    private var transactions = [Transaction]()
    
    public init(chain: BlockChain, maxConnections: Int = 1) {
        self.chain = chain
        self.maxConnections = maxConnections
    }
    
    public func start() {
        let network = chain.network
        for _ in peers.count..<maxConnections {
            let peer = Peer(host: network.dnsSeeds[1], network: network)
            peer.delegate = self
            peer.connect()
            peers[peer.host] = peer
        }
        if let delegate = delegate {
            delegate.peerGroupDidStart(self)
        }
    }
    
    public func stop() {
        for peer in peers.values {
            peer.delegate = nil
            peer.disconnect()
        }
        peers.removeAll()
        if let delegate = delegate {
            delegate.peerGroupDidStop(self)
        }
    }
    
    /// - Parameter filter: pubkey, pubkeyhash, scripthash...
    public func addFilter(_ filter: Data) {
        filters.append(filter)
    }
    
    public func sendTransaction(_ transaction: Transaction) {
        if let peer = peers.values.first {
            peer.sendTransaction(transaction)
        } else {
            transactions.append(transaction)
            start()
        }
    }
}

extension PeerGroup: PeerDelegate {
    public func peerDidConnect(_ peer: Peer) {
        if peers.values.filter({ $0.context.isSyncing }).isEmpty {
            let latestBlock = chain.latestBlockHash()
            peer.startSync(filters: filters, latestBlock: latestBlock)
        }
        if !transactions.isEmpty {
            for tx in transactions {
                peer.sendTransaction(tx)
            }
        }
    }
    
    public func peerDidDisconnect(_ peer: Peer) {
        peers[peer.host] = nil
        start()
    }
    
    public func peer(_ peer: Peer, didReceiveVersionMessage message: VersionMessage) {
        if message.userAgent.contains("Bitcoin ABC:0.16") {
            print("it's old version. Let's try to disconnect and connect to aother peer.")
            peer.disconnect()
        }
    }
    
    public func peer(_ peer: Peer, didReceiveMerkleBlock block: MerkleBlock, hash: Data) {
        let checkBlock = Block(version: block.version, prevBlock: block.prevBlock, merkleRoot: block.merkleRoot, timestamp: block.timestamp, bits: block.bits, nonce: block.nonce)
        guard checkBlock.checkPoW() else {
            print("insufficient proof of work!")
            return
        }
        guard block.isValid() else {
            print("merkleroot not match")
            return
        }
        do {
            try chain.addMerkleBlock(block, hash: hash)
        } catch let err {
            print("store merklerblock failed: \(err)")
        }
    }
    
    public func peer(_ peer: Peer, didReceiveTransaction tx: Transaction) {
        do {
            try chain.addTransaction(tx)
        } catch let err {
            print("store tx failed: \(err)")
        }
        if let delegate = delegate {
            delegate.peerGroupDidReceiveTransaction(self)
        }
    }
}



