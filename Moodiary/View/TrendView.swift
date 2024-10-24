//
//  TrendView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI
import Charts

struct TrendView: View {
    @State private var selectedPeriod: TrendPeriod = .week
    @State private var trendData: TrendData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
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
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        headerView()
                            .padding(.top)
                            .padding(.horizontal)
                        
                        dateSelectionView()
                            .padding(.top, 10)
                        
                        if let data = trendData {
                            moodLineChartView(data: data.moodTrend)
                            heatMapView(data: data.heatMap)
                            WordCloudView(items: data.wordCloud)
                            weekSummaryView(summary: data.summary)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: loadTrendData)
        .alert(isPresented: $showError) {
            Alert(
                title: Text("错误"),
                message: Text(errorMessage ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Text(formattedDateRange())
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
    }
    
    private func dateSelectionView() -> some View {
        HStack(spacing: 15) {
            periodButton(for: .month, label: "近一月")
            periodButton(for: .week, label: "近一周")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func periodButton(for period: TrendPeriod, label: String) -> some View {
        Button(action: {
            selectedPeriod = period
            loadTrendData()
        }) {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedPeriod == period ? Color.blue.opacity(0.2) : Color.clear)
                .foregroundColor(selectedPeriod == period ? .blue : .primary)
                .cornerRadius(15)
        }
    }
    
    private func formattedDateRange() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        
        let endDate = Date()
        let startDate: Date
        
        switch selectedPeriod {
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -6, to: endDate)!
        case .month:
            startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate)!
        }
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func moodLineChartView(data: [MoodData]) -> some View {
        componentView(height: 300) {
            VStack(alignment: .leading, spacing: 10) {
                Text("心情变化")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(data) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Mood", item.mood)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
            }
        }
    }
    
    private func heatMapView(data: [HeatMapData]) -> some View {
        componentView(height: 250) {
            VStack(alignment: .leading, spacing: 10) {
                Text("记录频率")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                HeatMapCalendarView(data: data)
                    .frame(height: 180)
                    .padding(.horizontal)
            }
        }
    }
    
    
    private func weekSummaryView(summary: String) -> some View {
        componentView(height: 200) {
            VStack(alignment: .leading, spacing: 10) {
                Text("本周总结")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Text(summary)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 5)
            }
        }
    }
    
    @ViewBuilder
    private func componentView(height: CGFloat, @ViewBuilder content: @escaping () -> some View) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(cardGradient)
                .frame(height: height)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            content()
        }
    }
    
    private func loadTrendData() {
        isLoading = true
        errorMessage = nil
        
        TrendManager.shared.getTrends(period: selectedPeriod) { result in
            isLoading = false
            
            switch result {
            case .success(let data):
                self.trendData = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}

// MARK: - Supporting Views
struct HeatMapCalendarView: View {
    let data: [HeatMapData]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<4) { row in
                HStack(spacing: 8) {
                    ForEach(0..<7) { column in
                        let index = row * 7 + column
                        if index < data.count {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorForCount(data[index].count))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("\(data[index].count)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.1)
        case 1: return Color.blue.opacity(0.2)
        case 2: return Color.blue.opacity(0.4)
        case 3: return Color.blue.opacity(0.6)
        default: return Color.blue.opacity(0.8)
        }
    }
}

struct TrendView_Previews: PreviewProvider {
    static var previews: some View {
        TrendView()
    }
}
