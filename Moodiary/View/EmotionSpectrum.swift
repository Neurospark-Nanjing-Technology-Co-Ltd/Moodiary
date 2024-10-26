//
//  EmotionSpectrum.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

struct EmotionSpectrum: View {
    let emotions: [MoodLabel]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(emotions.sorted(by: { $0.score > $1.score }), id: \.label) { emotion in
                    Rectangle()
                        .fill(colorForEmotion(emotion.label))
                        .frame(width: max(1, geometry.size.width * CGFloat(emotion.score)))
                }
            }
        }
        .frame(height: 30)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    func colorForEmotion(_ emotion: String) -> Color {
        switch emotion {
        case "sadness": return .blue
        case "disappointment": return .purple
        case "optimism": return .yellow
        case "neutral": return .gray
        case "desire": return .pink
        case "realization": return .mint
        case "caring": return .green
        case "approval": return .teal
        case "joy": return .orange
        case "disapproval": return .red
        case "nervousness": return .indigo
        case "grief": return .cyan
        case "remorse": return .brown
        case "annoyance": return .orange
        case "relief": return .mint
        case "admiration": return .yellow
        case "fear": return .purple
        case "love": return .pink
        case "confusion": return .gray
        case "surprise": return .orange
        case "amusement": return .green
        case "excitement": return .red
        case "curiosity": return .blue
        case "disgust": return .green
        case "embarrassment": return .pink
        case "pride": return .yellow
        case "anger": return .red
        case "gratitude": return .blue
        default: return .black
        }
    }
}
