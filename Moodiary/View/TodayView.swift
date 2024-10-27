//
//  TodayView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var showingInputSheet = false
    @State private var userInput = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
        startPoint: .top,
        endPoint: .bottom
    )
    let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white, Color(hex: "F8F9FA")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            backgroundGradient.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView()
                    moodView()
                    emotionSpectrumView()
                    quoteView()
                }
                .padding()
            }
            
            addButton()
        }
        .onAppear {
            viewModel.fetchTodayMood()
        }
        .sheet(isPresented: $showingInputSheet) {
            InputView(
                thought: $userInput,
                isPresented: $showingInputSheet,
                onSave: { content in
                    RecordManager.shared.createRecord(content: content, title: "Daily Mood") { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                viewModel.fetchTodayMood()
                                userInput = ""
                                showingInputSheet = false
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                showError = true
                                // 延迟关闭错误提示
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showError = false
                                }
                            }
                        }
                    }
                }
            )
        }
        .alert("保存失败", isPresented: $showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func headerView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("你好，F1reC!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("今天是变得更好的好日子")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
        }
    }
    
    func moodView() -> some View {
        componentView(height: 300) {
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 150, height: 150)
                    
                    CloudView(emotion: viewModel.topEmotion)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
                
                Text(viewModel.topEmotion)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
                Text(viewModel.comfortLanguage)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(maxWidth: 300)
            }
        }
    }
    
    func emotionSpectrumView() -> some View {
        componentView(height: 120) {
            VStack(alignment: .leading, spacing: 10) {
                Text("心情色谱")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.leading)
                
                EmotionSpectrum(emotions: viewModel.emotions)
            }
        }
    }
    
    func quoteView() -> some View {
        componentView(height: 200) {
            VStack(alignment: .leading, spacing: 8) {
                Text("此刻随想")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Text(viewModel.currentThought)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    func addButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    userInput = ""
                    showingInputSheet = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    @ViewBuilder
    func componentView(height: CGFloat, @ViewBuilder content: @escaping () -> some View) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(cardGradient)
                .frame(height: height)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            content()
        }
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
