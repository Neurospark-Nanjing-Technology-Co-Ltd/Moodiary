//
//  TrendData.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/27.
//


import Foundation
import Moya

// MARK: - Models
struct WordCloudItem: Identifiable {
    let id: String
    let word: String
    let weight: Int
}

struct HeatMapData: Identifiable {
    let id = UUID()
    let date: String
    let count: Int
}

struct MoodData: Identifiable {
    let id = UUID()
    let date: Date
    let mood: Double
}

struct TrendData {
    let moodTrend: [MoodData]
    let heatMap: [HeatMapData]
    let wordCloud: [WordCloudItem]
    let summary: String
}

// MARK: - API Response Models
struct TrendResponse: Codable {
    let code: Int
    let message: String
    let data: [HeatMapEntry]
}

struct HeatMapEntry: Codable {
    let recordDate: String
    let postCount: Int
}
