//
//  Emotion.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//


// Record.swift

struct Emotion: Codable {
    let label: String
    let score: Double
}

struct Record: Codable, Identifiable {
    let id: String
    let content: String
    let emotions: [Emotion]
    let createdAt: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case emotions
        case createdAt = "created_at"
        case tags
    }
}

struct RecordResponse: Codable {
    let code: Int
    let message: String
    let data: [Record]
}