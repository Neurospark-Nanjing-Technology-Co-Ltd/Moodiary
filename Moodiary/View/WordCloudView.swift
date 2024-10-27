//
//  WordCloudView.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

// MARK: - Word Cloud View
struct WordCloudView: View {
    let items: [WordCloudItem]
    @State private var positions: [CGPoint] = []
    
    // 将权重转换为字体大小
    private var words: [(String, CGFloat)] {
        items.map { item in
            // 将权重映射到15-30的字体大小范围
            let fontSize = mapWeight(item.weight)
            return (item.word, fontSize)
        }
    }
    
    // 将权重映射到字体大小
    private func mapWeight(_ weight: Int) -> CGFloat {
        // 假设权重范围是1-100，映射到15-30的字体大小
        let minSize: CGFloat = 15
        let maxSize: CGFloat = 30
        let weightRange = CGFloat(100 - 1)
        let sizeRange = maxSize - minSize
        
        return minSize + (CGFloat(weight - 1) / weightRange) * sizeRange
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text(word.0)
                        .font(.system(size: word.1))
                        .foregroundColor(randomColor(for: index))
                        .opacity(0.7)
                        .offset(x: positions.indices.contains(index) ? positions[index].x : 0,
                               y: positions.indices.contains(index) ? positions[index].y : 0)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: positions.indices.contains(index) ? positions[index] : .zero
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .onAppear {
                initializePositions(geometry: geometry)
                startAnimation()
            }
            .onDisappear {
                // 清理计时器
                Timer.cancelPreviousPerformRequests(withTarget: self)
            }
        }
    }
    
    // 初始化位置
    private func initializePositions(geometry: GeometryProxy) {
        positions = words.map { _ in
            CGPoint(
                x: CGFloat.random(in: -geometry.size.width/3...geometry.size.width/3),
                y: CGFloat.random(in: -geometry.size.height/3...geometry.size.height/3)
            )
        }
    }
    
    // 开始动画
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in 0..<positions.count {
                positions[i] = CGPoint(
                    x: positions[i].x + CGFloat.random(in: -1...1),
                    y: positions[i].y + CGFloat.random(in: -1...1)
                )
            }
        }
    }
    
    // 为每个词生成随机颜色
    private func randomColor(for index: Int) -> Color {
        let colors: [Color] = [
            .blue,
            .green,
            .orange,
            .purple,
            .pink
        ]
        
        let colorIndex = index % colors.count
        return colors[colorIndex].opacity(0.8)
    }
}

// MARK: - Preview Provider
struct WordCloudView_Previews: PreviewProvider {
    static var previews: some View {
        WordCloudView(items: [
            WordCloudItem(id: "1", word: "快乐", weight: 80),
            WordCloudItem(id: "2", word: "悲伤", weight: 60),
            WordCloudItem(id: "3", word: "平静", weight: 40),
            WordCloudItem(id: "4", word: "兴奋", weight: 70),
            WordCloudItem(id: "5", word: "焦虑", weight: 50)
        ])
        .frame(height: 300)
        .padding()
    }
}
