//
//  TodayViewModel.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

class TodayViewModel: ObservableObject {
    @Published var currentThought: String = ""
    @Published var topEmotion: String = ""
    @Published var comfortLanguage: String = ""
    @Published var behavioralGuidance: String = ""
    @Published var emotions: [Emotion] = []
    
    private let todayManager = TodayManager.shared
    
    func fetchTodayMood() {
        todayManager.getTodayMood { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todayMood):
                    self?.topEmotion = todayMood.topEmotion
                    self?.comfortLanguage = todayMood.comfortLanguage
                    self?.behavioralGuidance = todayMood.behavioralGuidance
                    if let firstEmotionSet = todayMood.data.first {
                        self?.emotions = firstEmotionSet.map { Emotion(label: $0.label, score: $0.score) }
                    }
                case .failure(let error):
                    print("Error fetching today's mood: \(error)")
                    // 处理错误,例如显示一个警告
                }
            }
        }
    }
    
    func postTodayMood() {
        let emotions = Dictionary(uniqueKeysWithValues: self.emotions.map { ($0.label, $0.score) })
        todayManager.postTodayMood(text: currentThought, emotions: emotions) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Successfully posted today's mood")
                    self?.fetchTodayMood() // 重新获取更新后的心情数据
                case .failure(let error):
                    print("Error posting today's mood: \(error)")
                    // 处理错误,例如显示一个警告
                }
            }
        }
    }
}
