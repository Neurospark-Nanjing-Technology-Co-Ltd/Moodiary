//
//  Emotion.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//

import Foundation

// 心情标签模型
struct MoodLabel: Codable {
    let label: String
    let score: Double
}

// 记录模型
struct Record: Codable, Identifiable {
    var id: Int { recordId }
    let userId: Int
    let recordId: Int
    let moodJson: [MoodLabel]?
    let content: String
}

struct RecordResponse: Codable {
    let code: Int
    let message: String
    let data: [Record]
}
