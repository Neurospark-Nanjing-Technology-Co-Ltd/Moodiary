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
    @Published var emotions: [MoodLabel] = []
    @Published var isLoading: Bool = false
    
    private let todayManager = TodayManager.shared
    
    func fetchTodayMood() {
        isLoading = true
        
        todayManager.getTodayMood { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let todayMood):
                    self?.topEmotion = todayMood.topEmotion ?? "平静"
                    self?.comfortLanguage = todayMood.comfortLanguage ?? "让我们开始记录今天的心情吧"
                    self?.currentThought = todayMood.content
                    
                    // 直接使用 moodJson 数组
                    if let moodLabels = todayMood.moodJson {
                        self?.emotions = moodLabels
                    } else {
                        self?.emotions = []
                    }
                    
                case .failure(let error):
                    print("获取今日心情失败: \(error.localizedDescription)")
                    // 可以在这里设置一些默认值
                    self?.topEmotion = "未知"
                    self?.comfortLanguage = "暂时无法获取心情数据"
                    self?.currentThought = ""
                    self?.emotions = []
                }
            }
        }
    }
}
