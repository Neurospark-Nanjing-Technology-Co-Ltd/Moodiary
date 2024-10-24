//
//  MoodData.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import Foundation

struct MoodData: Codable, Identifiable {
    let id: String
    let date: Date
    let mood: Double
}

struct HeatMapData: Codable, Identifiable {
    let id: String
    let date: Date
    let count: Int
}

struct TrendResponse: Codable {
    let code: Int
    let message: String
    let data: TrendData
}

struct TrendData: Codable {
    let moodTrend: [MoodData]
    let heatMap: [HeatMapData]
    let wordCloud: [WordCloudItem]
    let summary: String
}

struct WordCloudItem: Codable, Identifiable {
    let id: String
    let word: String
    let weight: Int
}
