//
//  TodayView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
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
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                CloudShape()
                    .fill(Color.blue.opacity(0.3 - Double(i) * 0.1))
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

struct TodayView: View {
    @State private var showingInputSheet = false
    @State private var currentThought = "我经由光阴，经由山水，经由乡村和城市，同样我也经由别人，经由一切他者以及由之引生的思绪和梦想而走成了我。那路途中的一切，有些与我擦肩而过从此天各一方，有些便永久驻进我的心魂，雕琢我，塑造我，锤炼我融入我而成为我。"
    
    let backgroundGradient = LinearGradient(gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]), startPoint: .top, endPoint: .bottom)
    let cardGradient = LinearGradient(gradient: Gradient(colors: [Color.white, Color(hex: "F8F9FA")]), startPoint: .top, endPoint: .bottom)
    
    let emotions: [Emotion] = [
        Emotion(label: "sadness", score: 0.5142688155174255),
        Emotion(label: "disappointment", score: 0.34392452239990234),
        Emotion(label: "optimism", score: 0.18355123698711395),
        Emotion(label: "neutral", score: 0.09777343273162842),
        Emotion(label: "desire", score: 0.06829964369535446),
        Emotion(label: "realization", score: 0.033430442214012146),
        Emotion(label: "caring", score: 0.018700357526540756),
        Emotion(label: "approval", score: 0.016513975337147713),
        Emotion(label: "joy", score: 0.015521684661507607),
        Emotion(label: "disapproval", score: 0.015389608219265938),
        Emotion(label: "nervousness", score: 0.014421362429857254),
        Emotion(label: "grief", score: 0.01187789998948574),
        Emotion(label: "remorse", score: 0.010495388880372047),
        Emotion(label: "annoyance", score: 0.009701424278318882),
        Emotion(label: "relief", score: 0.007125277537852526),
        Emotion(label: "admiration", score: 0.006984887644648552),
        Emotion(label: "fear", score: 0.006958952639251947),
        Emotion(label: "love", score: 0.006097970064729452),
        Emotion(label: "confusion", score: 0.003939824644476175),
        Emotion(label: "surprise", score: 0.003920560237020254),
        Emotion(label: "amusement", score: 0.0037957197055220604),
        Emotion(label: "excitement", score: 0.003023377386853099),
        Emotion(label: "curiosity", score: 0.0028412635438144207),
        Emotion(label: "disgust", score: 0.0018109313677996397),
        Emotion(label: "embarrassment", score: 0.0017967536114156246),
        Emotion(label: "pride", score: 0.0015587169909849763),
        Emotion(label: "anger", score: 0.0013835277641192079),
        Emotion(label: "gratitude", score: 0.0011857559438794851)
    ]
    
    var body: some View {
        ZStack {
            backgroundGradient.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView()
                    moodView()
                    emotionSpectrumView()
                    quoteView()
                    wordCloudView()
                }
                .padding()
            }
            
            addButton()
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
                    
                    CloudView()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
                
                Text("深呼吸，放松心情")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)

                Text("在这片宁静的蓝色中，让紧张慢慢消散。记住，你很强，一切都会好起来的。")
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
                    .padding(.bottom, 4)

                EmotionSpectrum(emotions: emotions)
                    .padding(.horizontal)
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
                
                Text(currentThought)
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
    
    func wordCloudView() -> some View {
        componentView(height: 300) {
            VStack(alignment: .leading, spacing: 10) {
                Text("心情词云")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                WordCloudView()
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
    
    func addButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
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
        .sheet(isPresented: $showingInputSheet) {
            InputView(thought: $currentThought, isPresented: $showingInputSheet)
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

struct WordCloudView: View {
    let words: [(String, CGFloat)] = [
        ("快乐", 30), ("悲伤", 25), ("奋", 20), ("焦虑", 22),
        ("平静", 18), ("愤怒", 15), ("满足", 28), ("困惑", 17),
        ("感恩", 24), ("孤独", 19), ("希望", 26), ("失望", 21)
    ]
    
    @State private var positions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text(word.0)
                        .font(.system(size: word.1))
                        .foregroundColor(.black)
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
                positions = words.map { _ in
                    CGPoint(
                        x: CGFloat.random(in: -geometry.size.width/3...geometry.size.width/3),
                        y: CGFloat.random(in: -geometry.size.height/3...geometry.size.height/3)
                    )
                }
                
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    for i in 0..<positions.count {
                        positions[i] = CGPoint(
                            x: positions[i].x + CGFloat.random(in: -1...1),
                            y: positions[i].y + CGFloat.random(in: -1...1)
                        )
                    }
                }
            }
        }
    }
}

struct EmotionSpectrum: View {
    let emotions: [Emotion]
    
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

struct Emotion: Identifiable {
    let id = UUID()
    let label: String
    let score: Double
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

struct InputView: View {
    @Binding var thought: String
    @Binding var isPresented: Bool
    @State private var tempThought: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $tempThought)
                    .padding()
                    .frame(minHeight: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding()
            }
            .navigationBarTitle("输入你的随想", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                },
                trailing: Button("保存") {
                    thought = tempThought
                    isPresented = false
                }
            )
        }
        .onAppear {
            tempThought = thought
        }
    }
}

