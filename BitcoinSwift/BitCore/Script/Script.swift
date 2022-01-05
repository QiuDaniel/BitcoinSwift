//
//  Script.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public class Script {
    
    private var chunks: [ScriptChunk]
    private var dataCache: Data?
    private var stringCache: String?
    
    public var data: Data {
        if let cache = dataCache {
            return cache
        }
        dataCache = chunks.reduce(Data.empty) { $0 + $1.chunkData }
        return dataCache!
    }
    
    public var string: String {
        if let cache = stringCache {
            return cache
        }
        let cache = chunks.map { $0.string }.joined(separator: " ")
        stringCache = cache
        return cache
    }
    
    public var hex: String {
        return data.hex
    }
    
    init(_ chunks: [ScriptChunk]? = nil) {
        if chunks == nil {
            self.chunks = [ScriptChunk]()
        } else {
            self.chunks = chunks!
        }
    }
    
    convenience init?(_ data: Data) {
        do {
            let chunks = try Script.parse(data)
            self.init(chunks)
        } catch {
            return nil
        }
    }
    
    convenience init?(hex: String) {
        let data = Data(hex: hex)
        self.init(data)
    }
    
}

private extension Script {
    
    static func parse(_ data: Data) throws -> [ScriptChunk] {
        guard !data.isEmpty else {
            return [ScriptChunk]()
        }

        var chunks = [ScriptChunk]()

        var i: Int = 0
        let count: Int = data.count

        while i < count {
            // Exit if failed to parse
            let chunk = try Script.parse(from: data, offset: i)
            chunks.append(chunk)
            i += chunk.range.count
        }
        return chunks
    }
}
