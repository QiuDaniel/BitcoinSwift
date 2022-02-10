//
//  Peer.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import Foundation

public protocol PeerDelegate: AnyObject {
    func peerDidConnect()
    func peerDidDisconnect()
    func peer(_ peer: Peer, didReceiveVersionMessage message: VersionMessage)
    func peer(_ peer: Peer, didReceiveGetDataMessage message: GetDataMessage)
    func peer(_ peer: Peer, didReceiveInventoryMessage message: InventoryMessage)
    func peer(_ peer: Peer, didReceiveBlockMessage message: BlockMessage)
    func peer(_ peer: Peer, didReceiveMerkleBlock block: MerkleBlock, hash: Data)
    func peer(_ peer: Peer, didReceiveTransaction tx: Transaction)
}

extension PeerDelegate {
    public func peerDidConnect() {}
    public func peerDidDisconnect() {}
    public func peer(_ peer: Peer, didReceiveVersionMessage message: VersionMessage) {}
    public func peer(_ peer: Peer, didReceiveGetDataMessage message: GetDataMessage) {}
    public func peer(_ peer: Peer, didReceiveInventoryMessage message: InventoryMessage) {}
    public func peer(_ peer: Peer, didReceiveBlockMessage message: BlockMessage) {}
    public func peer(_ peer: Peer, didReceiveMerkleBlock block: MerkleBlock, hash: Data) {}
    public func peer(_ peer: Peer, didReceiveTransaction tx: Transaction) {}
}

private let protocolVersion: Int32 = 70_015
private let bufferSize = 4096

public class Peer: NSObject {
    public let host: String
    public let network: Network
    public var port: UInt32 {
        return network.port
    }
    
    public weak var delegate: PeerDelegate?
    
    var latestBlock: Data
    private var verbose: Bool
    
    private var readStream: Unmanaged<CFReadStream>?
    private var writeStream: Unmanaged<CFWriteStream>?
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    let context = Context()
    
    class Context {
        var packets = Data()
        /// Transactions to be sent
        var transactions = [Data: Transaction]()

        var pingTime = Date()
        var estimatedHeight: Int32 = 0

        var sentVersion = false
        var sentVerack = false
        var gotVerack = false
        var sentGetAddr = false
        var sentFilterLoad = false
        var sentGetData = false
        var sentMemPool = false
        var sentGetBlocks = false

        var isSyncing = false
        var inventoryItems = [Data: Inventory]()
    }
    
    deinit {
        disconnect()
    }
    
    public convenience init(network: Network = .BTCtestnet, verbose: Bool = false) {
        self.init(host: network.dnsSeeds[Int(arc4random_uniform(UInt32(network.dnsSeeds.count)))], network: network, verbose: verbose)
    }
    
    public init(host: String, network: Network = .BTCtestnet, verbose: Bool = false) {
        self.host = host
        self.network = network
        self.verbose = verbose
        latestBlock = network.genesisBlock
    }
    
    public func connect() {
        if verbose {
            log("peer connecting")
        }
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host as CFString, port, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        inputStream.delegate = self
        outputStream.delegate = self

        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)

        inputStream.open()
        outputStream.open()
    }
    
    public func disconnect() {
        guard readStream != nil && readStream != nil else {
            return
        }

        inputStream.delegate = nil
        outputStream.delegate = nil
        inputStream.remove(from: .current, forMode: .common)
        outputStream.remove(from: .current, forMode: .common)

        inputStream.close()
        outputStream.close()
        readStream = nil
        writeStream = nil
        if let delegate = delegate {
            delegate.peerDidDisconnect()
        }
        if verbose {
            log("disconnected")
        }
    }
    
    public func startSync(filters: [Data] = [], latestBlock: Data) {
        self.latestBlock = latestBlock
        context.isSyncing = true
        if !context.sentFilterLoad {
            sendFilterLoadMessage(filters)
            context.sentFilterLoad = true
            if !context.sentMemPool {
                sendMemPoolMessage()
                context.sentMemPool = true
            }
        }
        
    }
}

// MARK: - StreamDelegate

extension Peer: StreamDelegate {
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch aStream {
        case let aStream as InputStream:
            switch eventCode {
            case .openCompleted:
                if verbose {
                    log("socket connected")
                }
            case .hasBytesAvailable:
                readAvailableStream(aStream)
            case .errorOccurred:
                if verbose {
                    log("socket error occurred")
                }
                disconnect()
            case .endEncountered:
                if verbose {
                    log("socket closed")
                }
                disconnect()
            default:
                break
            }
        case _ as OutputStream:
            switch eventCode {
            case .hasSpaceAvailable:
                "11111"
            case .errorOccurred:
                if verbose {
                    log("socket error occurred")
                }
                disconnect()
            case .endEncountered:
                if verbose {
                    log("socket closed")
                }
                disconnect()
            default:
                break
            }
        default:
            break
        }
    }
}

extension Peer {
    
    func readAvailableStream(_ stream: InputStream) {
        
    }
    
    func sendVersionMessage() {
        #warning("userAgent use BitcoinSwift")
        let version = VersionMessage(nonce: 0, userAgent: "/BitcoinKit:1.0.2/", latestBlock: -1)
        let payload = version.serialaize()
        let envelope = NetworkEnvelope(command: VersionMessage.command, payload: payload, network: network)
        send(envelope)
    }
    
    func sendVerackMessage() {
        let verack = VerAckMessage()
        let payload = verack.serialize()
        let envelope = NetworkEnvelope(command: VerAckMessage.command, payload: payload, network: network)
        send(envelope)
        context.pingTime = Date()
    }
    
    func sendFilterLoadMessage(_ filters: [Data]) {
        guard !filters.isEmpty else {
            return
        }
        let nTweak = arc4random_uniform(UInt32.max)
        var filter = BloomFilter(elements: filters.count, falsePositiveRate: 0.000_05, randomNonce: nTweak)
        filters.forEach { filter.add($0) }
        let filterMessage = filter.filterLoad(0)
        let envelope = NetworkEnvelope(command: filterMessage.command, payload: filterMessage.payload, network: network)
        send(envelope)
    }
    
    func sendMemPoolMessage() {
        let payload = Data.empty
        let envelope = NetworkEnvelope(command: "mempool", payload: payload, network: network)
        send(envelope)
    }
    
    func sendGetBlocksMessage() {
        let blockLocator = latestBlock
        let getBlocks = GetBlocksMessage(version: UInt32(protocolVersion), hashCount: 1, blockLocator: blockLocator, hashStop: Data(count: 32))
        let payload = getBlocks.serialize()
        let envelope = NetworkEnvelope(command: GetBlocksMessage.command, payload: payload, network: network)
        send(envelope)
    }
    
    func sendGetDataMessage(_ message: InventoryMessage) {
        let payload = message.serialize()
        let envelope = NetworkEnvelope(command: GetDataMessage.command, payload: payload, network: network)
        send(envelope)
    }
    
    func sendTransactionInventory(_ tx: Transaction) {
        let txId = tx.hash
        context.transactions[txId] = tx
        let inv = InventoryMessage(entries: [Inventory(type: .transaction, identifier: txId)])
        let payload = inv.serialize()
        let envelope = NetworkEnvelope(command: InventoryMessage.command, payload: payload, network: network)
        send(envelope)
    }
    
    func sendPongMessage(_ message: PongMessage) {
        let payload = message.serialize()
        let envelope = NetworkEnvelope(command: PongMessage.command, payload: payload, network: network)
        send(envelope)
    }
    
    func send(_ envelope: NetworkEnvelope) {
        if verbose {
            log("sending: \(envelope)")
        }
        let data = envelope.serialize()
        data.withUnsafeBytes { ptr -> Void in
            outputStream.write(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped, maxLength: data.count)
        }
    }
    
    func log(_ message: String) {
        print("\(host):\(port) \(message)")
    }
}

// MARK: - Handle Message

extension Peer {
    func handleVersionMessage(_ payload: Data) {
        let version = VersionMessage.parse(ByteStream(payload))
        context.estimatedHeight = version.latestBlock
        if verbose {
            log("got version \(version.version), useragent: \(version.userAgent), services: \(version.services)")
        }
        if let delegate = delegate {
            delegate.peer(self, didReceiveVersionMessage: version)
        }
        if !context.sentVerack {
            sendVerackMessage()
            context.sentVerack = true
        }
    }
    
    func handleVerackMessage(_ payload: Data) {
        if verbose {
            log("got verack in \(String(format: "%g", Date().timeIntervalSince(context.pingTime)))s")
        }
        context.gotVerack = true
        if let delegate = delegate {
            delegate.peerDidConnect()
        }
    }
    
    func handleAddressMessage(_ payload: Data) {
        
    }
    
    func handleGetDataMessage(_ payload: Data) {
        let message = GetDataMessage.parse(ByteStream(payload))
        if verbose {
            log("got getdata with \(message.datas.count) item(s)")
        }
        if let delegate = delegate {
            delegate.peer(self, didReceiveGetDataMessage: message)
        }
        for item in message.datas {
            switch item.type {
            case .transaction:
                if let tx = context.transactions[item.identifier] {
                    let payload = tx.serialize()
                    let envelope = NetworkEnvelope(command: "tx", payload: payload, network: network)
                    send(envelope)
                }
            default:
                break
            }
        }
    }
    
    func handleInventoryMessage(_ payload: Data) {
        let message = InventoryMessage.parse(ByteStream(payload))
        if verbose {
            log("got inv with \(message.entries.count) item(s)")
        }
        if let delegate = delegate {
            delegate.peer(self, didReceiveInventoryMessage: message)
        }
        let txItems = message.entries.filter{ $0.type == .transaction }
        let blockItems = message.entries.filter{ $0.type == .block || $0.type == .filtered }.map{ Inventory(type: .filtered, identifier: $0.identifier) }
        let filteredItems = txItems + blockItems
        guard !filteredItems.isEmpty else {
            return
        }
        sendGetDataMessage(InventoryMessage(entries: filteredItems))
        for item in filteredItems {
            context.inventoryItems[item.identifier] = item
        }
    }
    
    func handleBlockMessage(_ payload: Data) {
        let message = BlockMessage.parse(ByteStream(payload))
        if let delegate = delegate {
            delegate.peer(self, didReceiveBlockMessage: message)
        }
        let blockHash = message.block.blockHash
        context.inventoryItems[blockHash] = nil
        if context.inventoryItems.isEmpty {
            latestBlock = blockHash
            sendGetBlocksMessage()
        }
    }
    
    func handleMerkleBlockMessage(_ payload: Data) {
        let merkleBlock = MerkleBlock.parse(payload)
        let hash256 = Crypto.hash256(payload.prefix(80))
        let blockHash = Data(hash256.reversed())
        if let delegate = delegate {
            delegate.peer(self, didReceiveMerkleBlock: merkleBlock, hash: blockHash)
        }
        context.inventoryItems[blockHash] = nil
        if context.inventoryItems.isEmpty {
            latestBlock = blockHash
            sendGetBlocksMessage()
        }
    }
    
    func handleTransaction(_ payload: Data) {
        let tx = Transaction.parse(ByteStream(payload))
        if verbose {
            log("got tx: \(tx.hash)")
        }
        if let delegate = delegate {
            delegate.peer(self, didReceiveTransaction: tx)
        }
    }
    
    func handlePingMessage(_ payload: Data) {
        let message = PingMessage.parse(ByteStream(payload))
        let pongMessage = PongMessage(nonce: message.nonce)
        if verbose {
            log("got ping")
        }
        sendPongMessage(pongMessage)
    }
}
