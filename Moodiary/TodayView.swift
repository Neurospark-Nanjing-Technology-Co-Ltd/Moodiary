//
//  TodayView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI

struct TodayView: View {
    @State private var offset = CGSize.zero
    @State private var isMenuOpen = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(gradient: Gradient(colors: [Color(hex: "C5B4E3"), Color(hex: "D8BFD8")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部日期和铃铛
                HStack {
                    Text(formattedDate())
                        .font(.custom("Avenir-Medium", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
                
                // 虚拟形象区域
                ZStack {
                    // 半透明白色半圆背景
                    GeometryReader { geometry in
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: 0),
                                        radius: geometry.size.width * 0.8,
                                        startAngle: .degrees(0),
                                        endAngle: .degrees(10),
                                        clockwise: true)
                        }
                        .fill(Color.white.opacity(0.2))
                    }
                    .frame(height: 300)
                    
                    VStack {
                        // 虚拟形象图片
                        Image("Avatar1") // 请确保您的项目中有名为"Avatar1"的图片资源
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .offset(offset)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                    offset = CGSize(width: 5, height: 5)
                                }
                            }
                        
                        Text("马马虎虎")
                            .font(.custom("Avenir-Black", size: 24))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }
                .frame(height: 300)
                
                Spacer()
            }
            .blur(radius: isMenuOpen ? 10 : 0)
            
            // 浮动按钮和菜单选项
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        if isMenuOpen {
                            VStack(spacing: 15) {
                                MenuOption(icon: "camera.fill", text: "拍张照", color: .white)
                                MenuOption(icon: "waveform", text: "说句话", color: .white)
                                MenuOption(icon: "square.and.pencil", text: "写点字", color: .white)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 15)
                            .background(Color(hex: "8A2BE2").opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 70)
                            .padding(.trailing, 5)
                            .transition(.scale.combined(with: .opacity))
                            .frame(width: 180) // 设置固定宽度使菜单更紧凑
                        }
                        FloatingButton(isOpen: $isMenuOpen)
                    }
                }
                .padding(.trailing, 10) // 减少右侧padding使整体更靠右
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isMenuOpen)
    }
    
    // 格式化日期的辅助函数
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日"
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = Date()
        return dateFormatter.string(from: date)
    }
}

// 用于支持十六进制颜色代码的扩展
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

struct FloatingButton: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                isOpen.toggle()
            }
        }) {
            Image(systemName: isOpen ? "xmark" : "plus")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 60, height: 60)
                .background(Color(hex: "8A2BE2"))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .rotationEffect(.degrees(isOpen ? 45 : 0))
        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: isOpen)
    }
}

struct MenuOption: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            Spacer()
        }
    }
}
