//
//  Emotion.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//

import Foundation

struct Record: Codable, Identifiable {
    let id: String
    let content: String
    let emotions: [Emotion]
    let createdAt: Date
    let tags: [String]?
}

struct Emotion: Codable {
    let label: String
    let score: Double
}

struct RecordResponse: Codable {
    let code: Int
    let message: String
    let data: [Record]
}
