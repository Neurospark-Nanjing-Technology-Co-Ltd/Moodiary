//
//  CloudShape.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0.5*width, y: 0.4*height))
        path.addCurve(to: CGPoint(x: 0.9*width, y: 0.6*height),
                      control1: CGPoint(x: 0.7*width, y: 0.2*height),
                      control2: CGPoint(x: width, y: 0.4*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.8*height),
                      control1: CGPoint(x: 0.8*width, y: 0.8*height),
                      control2: CGPoint(x: 0.7*width, y: height))
        path.addCurve(to: CGPoint(x: 0.1*width, y: 0.6*height),
                      control1: CGPoint(x: 0.3*width, y: height),
                      control2: CGPoint(x: 0, y: 0.8*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.4*height),
                      control1: CGPoint(x: 0.2*width, y: 0.4*height),
                      control2: CGPoint(x: 0.3*width, y: 0.2*height))
        
        return path
    }
}

struct CloudView: View {
    @State private var phase: CGFloat = 0
    let emotion: String
    
    init(emotion: String = "neutral") {
        self.emotion = emotion
    }
    
    private func colorForEmotion(_ emotion: String) -> Color {
        switch emotion.lowercased() {
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
        default: return .gray
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                CloudShape()
                    .fill(colorForEmotion(emotion).opacity(0.3 - Double(i) * 0.1))
                    .scaleEffect(1.0 + CGFloat(i) * 0.1)
                    .offset(x: sin(phase + Double(i) * .pi * 2/3) * 10,
                            y: cos(phase + Double(i) * .pi * 2/3) * 10)
                    .animation(
                        Animation.easeInOut(duration: 4)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 1.3),
                        value: phase
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                phase += 2 * .pi
            }
        }
    }
}
