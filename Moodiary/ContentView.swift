import SwiftUI
import SwiftData
import Moodiary

// 添加以下导入语句
import Moodiary

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("今天")
                }
                .tag(0)
            
            RecordsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("记录")
                }
                .tag(1)
            
            TrendView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("趋势")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(3)
        }
        .accentColor(.purple) // 设置选中标签的颜色
        .onChange(of: selectedTab) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred() // 添加震动反馈
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
}
