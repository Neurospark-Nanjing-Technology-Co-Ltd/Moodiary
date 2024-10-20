import SwiftUI
import SwiftData
import Moodiary

// 添加以下导入语句
import Moodiary

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "cloud.sun.fill" : "cloud.sun")
                        Text("此刻")
                    }
                    .tag(0)
                
                RecordsView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "book.fill" : "book")
                        Text("记录")
                    }
                    .tag(1)
                
                TrendView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                        Text("趋势")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                        Text("我的")
                    }
                    .tag(3)
            }
            .accentColor(Color(hex: "4A90E2")) // 使用与 TodayView 相协调的蓝色
            .onChange(of: selectedTab) { _ in
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
}
