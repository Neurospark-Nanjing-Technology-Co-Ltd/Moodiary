import SwiftUI
import SwiftData

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
            
            TrendView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("趋势")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(.purple) // 设置选中标签的颜色
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
}
