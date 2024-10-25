//
//  Emotion.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//

import Foundation

struct Record: Codable, Identifiable {
    let id: Int
    let content: String
    let emotions: [Emotion]
    let tags: [String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "recordId"
        case content
        case emotions
        case tags
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        
        // 解析 emotions
        if let emotionsString = try container.decodeIfPresent(String.self, forKey: .emotions),
           let data = emotionsString.data(using: .utf8),
           let emotionsDict = try? JSONDecoder().decode([String: Double].self, from: data) {
            emotions = emotionsDict.map { Emotion(label: $0.key, score: $0.value) }
        } else {
            emotions = []
        }
        
        // 解析 tags
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        
        let dateFormatter = ISO8601DateFormatter()
        createdAt = dateFormatter.date(from: try container.decode(String.self, forKey: .createdAt)) ?? Date()
        updatedAt = dateFormatter.date(from: try container.decode(String.self, forKey: .updatedAt)) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        
        // 编码 emotions
        let emotionsDict = Dictionary(uniqueKeysWithValues: emotions.map { ($0.label, $0.score) })
        if let emotionsData = try? JSONEncoder().encode(emotionsDict),
           let emotionsString = String(data: emotionsData, encoding: .utf8) {
            try container.encode(emotionsString, forKey: .emotions)
        }
        
        // 编码 tags
        try container.encodeIfPresent(tags, forKey: .tags)
        
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
    }
}

struct Emotion: Codable, Identifiable {
    let id = UUID()
    let label: String
    let score: Double
    
    enum CodingKeys: String, CodingKey {
        case label
        case score
    }
}

struct RecordResponse: Codable {
    let code: Int
    let message: String
    let data: [Record]
}
