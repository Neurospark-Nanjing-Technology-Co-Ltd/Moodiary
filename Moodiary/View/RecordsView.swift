//
//  RecordsView.swift
//  Moodiary
//
//  Created by F1reC on 2024/10/3.
//

import SwiftUI

struct RecordsView: View {
    
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var records: [Record] = []
    @State private var selectedTag: String?
    @State private var errorMessage: String?
    @State private var showError = false
    
    private var filteredRecords: [Record] {
        if searchText.isEmpty {
            return records
        }
        return records.filter { record in
            record.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    headerView()
                        .padding(.horizontal)
                    
                    dateSelectionView()
                        .padding(.top, 10)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                    } else if records.isEmpty {
                        emptyStateView()
                    } else {
                        recordsList()
                    }
                    
                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
            }
            .navigationBarTitle("记录", displayMode: .large)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("错误"),
                    message: Text(errorMessage ?? "未知错误"),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
        .onAppear(perform: loadRecords)
        .sheet(isPresented: $showDatePicker) {
            DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .presentationDetents([.medium])
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Text(formattedDateHeader(selectedDate))
                .font(.title2)
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
    }
    
    private func recordsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredRecords, id: \.id) { record in
                    RecordCard(record: record)
                }
            }
            .padding()
        }
    }
    
    private func emptyStateView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("没有找到记录")
                .font(.headline)
            Text("这一天还没有任何记录")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
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
                .font(.system(size: 16, weight: .medium))
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
        }
        return isEarlierDate()
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
    
    private func loadRecords() {
        isLoading = true
        errorMessage = nil
        
        RecordManager.shared.getRecords(date: selectedDate, tag: selectedTag) { result in
            isLoading = false
            
            switch result {
            case .success(let fetchedRecords):
                records = fetchedRecords
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct RecordCard: View {
    let record: Record
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Emotions View
            EmotionSpectrum(emotions: record.moodJson!)
                .frame(height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // Content Preview
            Text(record.content)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .lineSpacing(4)
            
            // Timestamp
//            Text(formattedDate(record.createdAt))
//                .font(.caption)
//                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }
}


struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsView()
    }
}

