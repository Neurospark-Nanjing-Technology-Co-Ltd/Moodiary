//
//  TodayView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI

struct TodayView: View {
    let componentColor = Color(hex: "93d5dc").opacity(0.8)
    let circleColor = Color(hex: "12aa9c")
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // 白色背景
            
            ScrollView {
                VStack(spacing: 15) {
                    componentView(height: 200) {
                        Circle()
                            .fill(circleColor)
                            .padding()
                    }
                    componentView(height: 100)
                    componentView(height: 150)
                    componentView(height: 300) {
                        WordCloudView()
                    }
                }
                .padding()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // 这里添加按钮点击后的操作
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 60)
                            .background(circleColor)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    @ViewBuilder
    func componentView(height: CGFloat, @ViewBuilder content: @escaping () -> some View = { EmptyView() }) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(componentColor)
                .frame(height: height)
                .overlay(content())
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(componentColor)
                        .blur(radius: 10)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct WordCloudView: View {
    let words: [(String, CGFloat)] = [
        ("快乐", 30), ("悲伤", 25), ("兴奋", 20), ("焦虑", 22),
        ("平静", 18), ("愤怒", 15), ("满足", 28), ("困惑", 17),
        ("感恩", 24), ("孤独", 19), ("希望", 26), ("失望", 21)
    ]
    
    var body: some View {
        ZStack {
            ForEach(words, id: \.0) { word in
                Text(word.0)
                    .font(.system(size: word.1))
                    .foregroundColor(.black)
                    .opacity(0.7)
                    .offset(x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -80...80))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}