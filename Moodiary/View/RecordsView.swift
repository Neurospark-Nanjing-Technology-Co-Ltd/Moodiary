//
//  RecordsView.swift
//  Moodiary
//
//  Created by F1reC on 2024/10/3.
//

import SwiftUI

struct RecordsView: View {
    // MARK: - 状态属性
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var records: [Record] = []
    @State private var selectedTag: String?
    @State private var errorMessage: String?

    
    
    // MARK: - 过滤后的记录
    private var filteredRecords: [Record] {
        if searchText.isEmpty {
            return records
        }
        return records.filter { record in
            record.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    let fullText = "我经由光阴，经由山水，经由乡村和城市，同样我也经由别人，经由一切他者以及由之引生的思绪和梦想而走成了我。那路途中的一切，有些与我擦肩而过从此天各一方，有些便永久驻进我的心魂，雕琢我，塑造我，锤炼我融入我而成为我。"
    
    // MARK: - 主体视图
    var body: some View {
        VStack(spacing: 20) {
            headerView()
                .padding(.top)
                .padding(.horizontal)
            
            dateSelectionView()
                .padding(.top, 10)
            
            textPreviewView()
                .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 这里添加其他内容
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear(perform: loadRecords)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showDatePicker) {
            DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .presentationDetents([.medium])
        }
    
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
    
    private func headerView() -> some View {
        HStack {
            Text(formattedDateHeader(selectedDate))
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            searchBar
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("搜索...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .frame(width: 180)
    }
    
    private func dateSelectionView() -> some View {
        HStack(spacing: 15) {
            dateButton(for: nil, label: "更早")
            dateButton(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, label: "昨天")
            dateButton(for: Date(), label: "今天")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func textPreviewView() -> some View {
        Button(action: {
        }) {
            VStack(spacing: 10) {
                EmotionSpectrum(emotions: sampleEmotions)
                    .frame(height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(String(fullText.prefix(50)) + "...")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color(hex: "F8F9FA")]), startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
    }
    private func dateButton(for date: Date?, label: String) -> some View {
        Button(action: {
            if let date = date {
                selectedDate = date
            } else {
                showDatePicker = true
            }
        }) {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected(date) ? Color.blue.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected(date) ? .blue : .primary)
                .cornerRadius(15)
        }
    }
    
    private func isSelected(_ date: Date?) -> Bool {
        if let date = date {
            return Calendar.current.isDate(selectedDate, inSameDayAs: date)
        } else {
            return isEarlierDate()
        }
    }
    
    private func isEarlierDate() -> Bool {
        !Calendar.current.isDateInToday(selectedDate) && !Calendar.current.isDateInYesterday(selectedDate)
    }
    
    private func formattedDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    // 示例情绪数据，您可以根据需要调整
    private let sampleEmotions: [Emotion] = [
        Emotion(label: "joy", score: 0.3),
        Emotion(label: "sadness", score: 0.2),
        Emotion(label: "optimism", score: 0.15),
        Emotion(label: "neutral", score: 0.1),
        Emotion(label: "love", score: 0.25)
    ]
}

struct FullTextView: View {
    let text: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
            
            
            
            ScrollView {
                Text(text)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}




struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsView()
    }
}
