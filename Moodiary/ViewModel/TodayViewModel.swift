//
//  TodayViewModel.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

class TodayViewModel: ObservableObject {
    @Published var topEmotion: String = ""
    @Published var comfortLanguage: String = ""
    @Published var currentThought: String = ""
    @Published var emotions: [Emotion] = []  // 添加这行
    
    private let todayManager = TodayManager.shared
    
    func fetchTodayMood() {
        todayManager.getTodayMood { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todayMood):
                    self?.topEmotion = todayMood.topEmotion ?? ""
                    self?.comfortLanguage = todayMood.comfortLanguage ?? ""
                    self?.currentThought = todayMood.content
                    // 解析 moodJson 并更新 emotions
                    if let moodJson = todayMood.moodJson,
                       let data = moodJson.data(using: .utf8),
                       let jsonResult = try? JSONDecoder().decode([String: Double].self, from: data) {
                        self?.emotions = jsonResult.map { Emotion(label: $0.key, score: $0.value) }
                    }
                case .failure(let error):
                    print("获取今日心情失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func postTodayMood(content: String) {
        todayManager.postTodayMood(content: content) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("成功发布今日心情")
                    self?.fetchTodayMood()  // 重新获取今日心情数据
                case .failure(let error):
                    print("发布失败: \(error.localizedDescription)")
                }
            }
        }
    }
}
