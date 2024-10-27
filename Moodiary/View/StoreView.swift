import SwiftUI

struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
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
                Text("兑换中心")
                    .font(.headline)
                Spacer()
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
        NavigationView {
            StoreView()
        }
    }
}
