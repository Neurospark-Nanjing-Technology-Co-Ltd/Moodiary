//
//  TodayView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI
import CoreHaptics

struct TodayView: View {
    @State private var offset = CGSize.zero
    @State private var isMenuOpen = false
    @State private var showTextInput = false
    @State private var inputText = ""
    @State private var records: [String] = []
    @State private var engine: CHHapticEngine?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: [Color(hex: "C5B4E3"), Color(hex: "D8BFD8")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
            .blur(radius: isMenuOpen ? 10 : 0)
            
            ScrollView {
                VStack(spacing: 20) {
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
                            Image("Avatar1")
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
                    
                    // 新的记录展示区域
                    RecordsScrollView(records: records, onDelete: deleteRecord)
                        .frame(height: 100)
                    
                    // 添加叠放小组件
                    StackedWidgetsView()
                    
                    // 添加词云图
                    WordCloudView()
                        .frame(height: 200)
                    
                    Spacer(minLength: 50) // 为底部留出空间
                }
            }
            .allowsHitTesting(!isMenuOpen)
            
            // 浮动按钮和菜单选项
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        if isMenuOpen {
                            VStack(spacing: 15) {
                                MenuOption(icon: "camera.fill", text: "拍张照", color: .white) {
                                    performHapticFeedback()
                                    // 其他操作...
                                }
                                MenuOption(icon: "waveform", text: "说句话", color: .white) {
                                    // 添加语音功能的操作
                                    print("语音功能待实现")
                                }
                                MenuOption(icon: "square.and.pencil", text: "写点字", color: .white) {
                                    showTextInput = true
                                    isMenuOpen = false
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 15)
                            .background(Color(hex: "8A2BE2").opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 70)
                            .padding(.trailing, 5)
                            .transition(.scale.combined(with: .opacity))
                            .frame(width: 165)
                        }
                        FloatingButton(isOpen: $isMenuOpen)
                    }
                }
                .padding(.trailing, 30) // 减少右侧padding使整体更靠右
            }
            
            // 添加文字输入框
            if showTextInput {
                TextInputView(isPresented: $showTextInput, text: $inputText, onSubmit: {
                    if !inputText.isEmpty {
                        records.insert(inputText, at: 0)  // 在数组开头插入新记录
                        inputText = ""
                    }
                })
                .transition(.move(edge: .top))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isMenuOpen)
        .onAppear(perform: prepareHaptics)
        .onTapGesture {
            // 点击空白处时重置所有 RecordBox 的状态
            NotificationCenter.default.post(name: .resetRecordBoxes, object: nil)
        }
    }
    
    // 添加删除记录的方法
    func deleteRecord(_ record: String) {
        if let index = records.firstIndex(of: record) {
            records.remove(at: index)
        }
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

    // 添加 prepareHaptics 函数
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("触觉引擎启动失败: \(error.localizedDescription)")
        }
    }

    // 添加 performHapticFeedback 函数
    func performHapticFeedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("触觉反馈失败: \(error.localizedDescription)")
        }
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
    var action: () -> Void

    var body: some View {
        Button(action: action) {
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
}

// 新增的 RecordsScrollView 组件
struct RecordsScrollView: View {
    let records: [String]
    let onDelete: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(records, id: \.self) { record in
                    RecordBox(text: record, onDelete: {
                        onDelete(record)
                    })
                }
            }
            .padding(.horizontal)
        }
    }
}

// 新增的 RecordBox 组件
struct RecordBox: View {
    let text: String
    let onDelete: () -> Void
    @State private var showDeleteOption = false
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            VStack {
                Text(text.prefix(20))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(8)
            }
            .frame(width: 100, height: 80)
            .background(showDeleteOption ? Color.red.opacity(0.3) : Color.white.opacity(0.2))
            .cornerRadius(10)
            
            if showDeleteOption {
                Button(action: {
                    onDelete()
                    resetState()
                }) {
                    Text("删除")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .cornerRadius(5)
                }
                .offset(y: 45)
            }
        }
        .frame(width: 100) // 确保每个方框有固定宽度
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    showDeleteOption = true
                    startTimer()
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: .resetRecordBoxes)) { _ in
            resetState()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            resetState()
        }
    }
    
    private func resetState() {
        showDeleteOption = false
        timer?.invalidate()
        timer = nil
    }
}

extension Notification.Name {
    static let resetRecordBoxes = Notification.Name("resetRecordBoxes")
}

// 添加 TextInputView
struct TextInputView: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // 半透明紫色背景
            Color(hex: "8A2BE2").opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 返回按钮和标题
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("写点字")
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                    // 添加一个空的视图来平衡布局
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                .padding(.bottom, 20)

                VStack(spacing: 15) {
                    TextField("输入你的想法...", text: $text)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .focused($isFocused)

                    Button(action: {
                        onSubmit()
                        isPresented = false
                    }) {
                        Text("提交")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "8A2BE2"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                Spacer()
            }
        }
        .transition(.move(edge: .top))
        .onAppear {
            isFocused = true
        }
    }
}
struct StackedWidgetsView: View {
    @State private var currentIndex = 0
    let widgets: [WidgetData] = [
        WidgetData(title: "今日心情", color: Color(hex: "8A2BE2")),
        WidgetData(title: "待办事项", color: Color(hex: "9370DB")),
        WidgetData(title: "每日提醒", color: Color(hex: "BA55D3"))
    ]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<widgets.count, id: \.self) { index in
                    WidgetView(data: widgets[index])
                        .frame(width: geometry.size.width)
                }
            }
            .frame(width: geometry.size.width * CGFloat(widgets.count), alignment: .leading)
            .offset(x: -CGFloat(currentIndex) * geometry.size.width)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        if value.translation.width < -threshold {
                            withAnimation(.spring()) {
                                currentIndex = (currentIndex + 1) % widgets.count
                            }
                        } else if value.translation.width > threshold {
                            withAnimation(.spring()) {
                                currentIndex = (currentIndex - 1 + widgets.count) % widgets.count
                            }
                        }
                    }
            )
        }
        .frame(height: 200)
        .onAppear {
            startAutoSlide()
        }
    }
    
    private func startAutoSlide() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            withAnimation(.spring()) {
                currentIndex += 1
            }
        }
    }
}

struct WidgetData {
    let title: String
    let color: Color
}

struct WidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack {
            Text(data.title)
                .font(.headline)
                .foregroundColor(.white)
            
            // 这里可以添加更多的内容，如图标、数据等
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(data.color)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
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
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .offset(x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -80...80))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300) // 增加高度到300
        .background(Color(hex: "8A2BE2").opacity(0.3))
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 10) // 添加垂直方向的内边距
    }
}

