import SwiftUI

// 添加 Product 结构体定义
struct Product: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let pointsCost: Int
    let stock: Int
    let imageUrl: String
}

// 添加 Order 结构体定义
struct Order: Identifiable {
    let id = UUID()
    let productName: String
    let date: Date
    let status: String
    let pointsCost: Int
}

struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var products: [Product] = [
        Product(name: "商品1", description: "这是商品1的描述", pointsCost: 100, stock: 10, imageUrl: "https://example.com/image1.jpg"),
        Product(name: "商品2", description: "这是商品2的描述", pointsCost: 200, stock: 5, imageUrl: "https://example.com/image2.jpg"),
        Product(name: "商品3", description: "这是商品3的描述", pointsCost: 150, stock: 8, imageUrl: "https://example.com/image3.jpg"),
        Product(name: "商品4", description: "这是商品4的描述", pointsCost: 300, stock: 3, imageUrl: "https://example.com/image4.jpg")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                Spacer()
                Text("")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: OrderHistoryView()) {
                    Text("订单记录")
                        .foregroundColor(.blue)
                }
                NavigationLink(destination: AddressListView()) {
                    Text("地址")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // 美化后的搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("搜索商品", text: $searchText)
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // 商品列表
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(products) { product in
                        StoreItemView(product: product)
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

struct AddressListView: View {
    @State private var addresses: [Address] = []
    @State private var showingAddAddress = false
    
    var body: some View {
        List {
            ForEach(addresses) { address in
                AddressRow(address: address)
            }
            .onDelete(perform: deleteAddress)
        }
        .navigationTitle("地址管理")
        .navigationBarItems(trailing: Button(action: { showingAddAddress = true }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddAddress) {
            AddAddressView(addresses: $addresses)
        }
    }
    
    func deleteAddress(at offsets: IndexSet) {
        addresses.remove(atOffsets: offsets)
    }
}

struct Address: Identifiable {
    let id = UUID()
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
}

struct AddressRow: View {
    let address: Address
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(address.street)
                .font(.headline)
            Text("\(address.city), \(address.state) \(address.postalCode)")
                .font(.subheadline)
            Text(address.country)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct AddAddressView: View {
    @Binding var addresses: [Address]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("街道", text: $street)
                TextField("城市", text: $city)
                TextField("州/省", text: $state)
                TextField("邮政编码", text: $postalCode)
                TextField("国家", text: $country)
            }
            .navigationTitle("添加新地址")
            .navigationBarItems(leading: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("保存") {
                let newAddress = Address(street: street, city: city, state: state, postalCode: postalCode, country: country)
                addresses.append(newAddress)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct StoreItemView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)
                
                Text(product.name)
                    .font(.caption)
                    .padding(5)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(5)
                    .padding(5)
            }
            
            Text(product.description)
                .font(.caption)
                .lineLimit(2)
            
            HStack {
                Text("\(product.pointsCost) 积分")
                    .foregroundColor(.orange)
                    .font(.caption)
                Spacer()
                Text("库存: \(product.stock)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                // 兑换操作
            }) {
                Text("购买")
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

struct OrderHistoryView: View {
    @State private var orders: [TransactionRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: ErrorWrapper?
    
    struct ErrorWrapper: Identifiable {
        let id = UUID()
        let error: String
    }
    
    var body: some View {
        List {
            ForEach(orders) { order in
                VStack(alignment: .leading) {
                    Text(order.description)
                        .font(.headline)
                    Text("类型: \(order.transactionType)")
                        .font(.subheadline)
                    Text("金额: \(order.changeAmount)")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("订单记录")
        .onAppear(perform: loadOrderHistory)
        .overlay(Group {
            if isLoading {
                ProgressView()
            }
        })
        .alert(item: $errorMessage) { errorWrapper in
            Alert(title: Text("错误"), message: Text(errorWrapper.error), dismissButton: .default(Text("确定")))
        }
    }
    
    private func loadOrderHistory() {
        isLoading = true
        OrderManager.shared.getOrderHistory { result in
            isLoading = false
            switch result {
            case .success(let response):
                self.orders = response.data.rows
            case .failure(let error):
                self.errorMessage = ErrorWrapper(error: error.localizedDescription)
            }
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoreView()
        }
    }
}
