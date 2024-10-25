import SwiftUI

struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = "全部商品"
    let tabs = ["全部商品", "原神", "绝区零", "崩坏: 星穹铁道", "崩坏3"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Button(action: {
                    // 返回操作
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                Spacer()
                Text("兑换中心")
                    .font(.headline)
                Spacer()
                Text("明细")
                    .foregroundColor(.blue)
            }
            .padding()
            
            // 米游币显示
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("3714")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    // 获取米游币操作
                }) {
                    Text("获取米游币")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                }
            }
            .padding()
            
            // 选项卡
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(selectedTab == tab ? Color.blue : Color.clear)
                            .foregroundColor(selectedTab == tab ? .white : .black)
                            .cornerRadius(15)
                            .onTapGesture {
                                selectedTab = tab
                            }
                    }
                }
                .padding()
            }
            
            // 商品列表
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(0..<4) { _ in
                        StoreItemView()
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

struct StoreItemView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                Color.gray.opacity(0.1)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(10)
                
                Text("本月限购 0/1")
                    .font(.caption)
                    .padding(5)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(5)
                    .padding(5)
            }
            
            Text("【未定事件簿】未名晶片×100")
                .font(.caption)
                .lineLimit(2)
            
            HStack {
                Text("3000 米游币")
                    .foregroundColor(.orange)
                    .font(.caption)
                Spacer()
                Text("库存300")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                // 兑换操作
            }) {
                Text("即将开放")
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
