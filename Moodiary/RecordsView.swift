//
//  RecordsView.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//
import SwiftUI
import SwiftData


// MARK: - 主视图
struct RecordsView: View {
    // MARK: - 状态属性
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var records: [Record] = []
    @State private var selectedTag: String?
    @State private var errorMessage: String?
    
    let tags = ["全部", "快乐", "悲伤", "愤怒", "平静"]
    
    // MARK: - 过滤后的记录
    private var filteredRecords: [Record] {
        if searchText.isEmpty {
            return records
        }
        return records.filter { record in
            record.content.localizedCaseInsensitiveContains(searchText) ||
            record.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }
    
    // MARK: - 主体视图
    var body: some View {
        VStack(spacing: 16) {
            // 顶部日期和搜索栏
            headerView()
            
            // 日期选择栏
            dateSelectionView()
            
            // 标签选择栏
            tagSelectionView
            
            // 主要内容区域
            contentView
        }
        .background(Color(UIColor.systemBackground))
        .onAppear(perform: loadRecords)
    }
    
    // MARK: - 子视图
    private var contentView: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(message: error)
            } else if filteredRecords.isEmpty {
                emptyView
            } else {
                recordsList
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text(message)
                .multilineTextAlignment(.center)
            Button("重试") {
                loadRecords()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            Spacer()
        }
        .padding()
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("没有找到记录")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var recordsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredRecords) { record in
                    RecordCardView(record: record)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Text(formattedDateHeader(selectedDate))
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            searchBar
        }
        .padding(.horizontal)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("搜索...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .frame(width: 150)
    }
    
    private func dateSelectionView() -> some View {
        HStack(spacing: 12) {
            dateButton(for: nil, label: "更早")
            dateButton(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, label: "昨天")
            dateButton(for: Date(), label: "今天")
        }
        .padding(.horizontal)
    }
    
    private func dateButton(for date: Date?, label: String) -> some View {
        Button(action: {
            if let date = date {
                selectedDate = date
                loadRecords()
            } else {
                showDatePicker = true
            }
        }) {
            Text(label)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected(date) ? Color.blue.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected(date) ? .blue : .primary)
                .cornerRadius(8)
        }
    }
    
    private var tagSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tags, id: \.self) { tag in
                    tagButton(tag)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func tagButton(_ tag: String) -> some View {
        Button(action: {
            selectedTag = tag == "全部" ? nil : tag
            loadRecords()
        }) {
            Text(tag)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    (selectedTag == tag || (tag == "全部" && selectedTag == nil)) ?
                    Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                )
                .foregroundColor(
                    (selectedTag == tag || (tag == "全部" && selectedTag == nil)) ?
                    .blue : .primary
                )
                .cornerRadius(8)
        }
    }
    
    // MARK: - 辅助方法
    private func isSelected(_ date: Date?) -> Bool {
        if let date = date {
            return Calendar.current.isDate(selectedDate, inSameDayAs: date)
        }
        return !Calendar.current.isDateInToday(selectedDate) &&
               !Calendar.current.isDateInYesterday(selectedDate)
    }
    
    private func formattedDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    private func loadRecords() {
        isLoading = true
        errorMessage = nil
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            RecordManager.shared.getRecords(date: selectedDate, tag: selectedTag) { result in
                isLoading = false
                
                switch result {
                case .success(let fetchedRecords):
                    records = fetchedRecords
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - 记录卡片视图
struct RecordCardView: View {
    let record: Record
    @State private var showFullText = false
    
    var body: some View {
        Button(action: { showFullText = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // 情绪谱
                EmotionSpectrum(emotions: record.emotions)
                    .frame(height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // 标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(record.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.footnote)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // 内容预览
                Text(record.content)
                    .lineLimit(2)
                    .font(.body)
                    .foregroundColor(.primary)
                
                // 时间
                Text(formattedDate(record.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showFullText) {
            FullTextView(record: record)
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 全文视图
struct FullTextView: View {
    let record: Record
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    EmotionSpectrum(emotions: record.emotions)
                        .frame(height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // 标签
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(record.tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    // 内容
                    Text(record.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(8)
                    
                    // 时间
                    Text(formattedDate(record.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("详细内容")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 情绪谱视图
struct EmotionSpectrum: View {
    let emotions: [Emotion]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(emotions.indices, id: \.self) { index in
                    Rectangle()
                        .fill(colorForEmotion(emotions[index].label))
                        .frame(width: geometry.size.width * CGFloat(emotions[index].score))
                }
            }
        }
    }
    
    private func colorForEmotion(_ label: String) -> Color {
        switch label.lowercased() {
        case "joy": return .yellow
        case "sadness": return .blue
        case "anger": return .red
        case "fear": return .purple
        case "disgust": return .green
        case "neutral": return .gray
        case "optimism": return .orange
        case "love": return .pink
        default: return .gray
        }
    }
}

// MARK: - 预览支持
struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsView()
    }
}
