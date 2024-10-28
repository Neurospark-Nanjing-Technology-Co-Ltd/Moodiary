import SwiftUI


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
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: ErrorWrapper?
    
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
                    Text("History")
                        .foregroundColor(.blue)
                }
                NavigationLink(destination: AddressListView()) {
                    Text("Address")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // 美化后的搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search products", text: $searchText)
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
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(products) { product in
                            StoreItemView(product: product)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadProducts)
        .alert(item: $errorMessage) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error), dismissButton: .default(Text("OK")))
        }
    }
    
    private func loadProducts() {
        isLoading = true
        ProductManager.shared.getProducts { result in
            isLoading = false
            switch result {
            case .success(let products):
                self.products = products
            case .failure(let error):
                self.errorMessage = ErrorWrapper(error: error.localizedDescription)
            }
        }
    }
}

struct AddressListView: View {
    @State private var addresses: [Address] = []
    @State private var isLoading = false
    @State private var errorMessage: ErrorWrapper?
    @State private var showingAddAddressSheet = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            ForEach(addresses) { address in
                AddressRow(address: address)
            }
            .onDelete(perform: deleteAddress)
        }
        .navigationTitle("Address List")
        .onAppear(perform: loadAddresses)
        .overlay(Group {
            if isLoading {
                ProgressView()
            }
        })
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddAddressSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAddressSheet) {
            AddAddressView(isPresented: $showingAddAddressSheet, onAddressAdded: loadAddresses)
        }
    }
    
    private func loadAddresses() {
        isLoading = true
        AddressManager.shared.getAddresses { result in
            isLoading = false
            switch result {
            case .success(let response):
                self.addresses = response.data
            case .failure(let error):
                self.alertTitle = "Error"
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
    
    private func deleteAddress(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let addressToDelete = addresses[index]
        
        isLoading = true
        AddressManager.shared.deleteAddress(addressId: addressToDelete.id) { result in
            isLoading = false
            switch result {
            case .success:
                addresses.remove(at: index)
                alertTitle = "Success"
                alertMessage = "Address deleted successfully"
            case .failure(let error):
                alertTitle = "Delete Failed"
                alertMessage = error.localizedDescription
            }
            showingAlert = true
        }
    }
}

struct AddAddressView: View {
    @Binding var isPresented: Bool
    var onAddressAdded: () -> Void
    
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Address Information")) {
                    TextField("Street", text: $street)
                    TextField("City", text: $city)
                    TextField("State/Province", text: $state)
                    TextField("Postal Code", text: $postalCode)
                    TextField("Country", text: $country)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Address")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                addAddress()
            })
            .disabled(isLoading)
            .overlay(Group {
                if isLoading {
                    ProgressView()
                }
            })
        }
    }
    
    private func addAddress() {
        isLoading = true
        errorMessage = nil
        
        AddressManager.shared.addAddress(street: street, city: city, state: state, postalCode: postalCode, country: country) { result in
            isLoading = false
            switch result {
            case .success:
                isPresented = false
                onAddressAdded()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
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

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}

struct StoreItemView: View {
    let product: Product
    @State private var showingPurchaseSheet = false
    @State private var quantity = 1
    @State private var selectedAddressId: Int?
    @State private var addresses: [Address] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
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
                Text("\(product.pointsCost) Points")
                    .foregroundColor(.orange)
                    .font(.caption)
                Spacer()
                Text("Stock: \(product.stock)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                showingPurchaseSheet = true
            }) {
                Text("Purchase")
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
        .sheet(isPresented: $showingPurchaseSheet) {
            PurchaseView(product: product, quantity: $quantity, selectedAddressId: $selectedAddressId, addresses: $addresses, isLoading: $isLoading, errorMessage: $errorMessage, onPurchase: performPurchase, showingAlert: $showingAlert, alertTitle: $alertTitle, alertMessage: $alertMessage)
        }
        .onAppear(perform: loadAddresses)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func loadAddresses() {
        AddressManager.shared.getAddresses { result in
            switch result {
            case .success(let response):
                self.addresses = response.data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func performPurchase() {
        guard let addressId = selectedAddressId else {
            errorMessage = "Please select an address"
            return
        }
        
        isLoading = true
        PaymentManager.shared.createPayment(productId: product.id, quantity: quantity, addressId: addressId) { result in
            isLoading = false
            switch result {
            case .success(let response):
                if response.code == 0 {
                    showingPurchaseSheet = false
                    alertTitle = "Purchase Successful"
                    alertMessage = "You have successfully purchased the product. Order ID: \(response.data?.orderId ?? 0)"
                } else {
                    alertTitle = "Purchase Failed"
                    alertMessage = response.message
                }
                showingAlert = true
            case .failure(let error):
                alertTitle = "Purchase Failed"
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}

struct PurchaseView: View {
    let product: Product
    @Binding var quantity: Int
    @Binding var selectedAddressId: Int?
    @Binding var addresses: [Address]
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onPurchase: () -> Void
    @Binding var showingAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Information")) {
                    Text(product.name)
                    Text("Unit Price: \(product.pointsCost) Points")
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...product.stock)
                    Text("Total: \(product.pointsCost * quantity) Points")
                }
                
                Section(header: Text("Select Address")) {
                    Picker("Address", selection: $selectedAddressId) {
                        Text("Please select an address").tag(nil as Int?)
                        ForEach(addresses) { address in
                            Text("\(address.street), \(address.city)").tag(address.id as Int?)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Confirm Purchase")
            .navigationBarItems(trailing: Button("Purchase") {
                onPurchase()
            })
            .disabled(isLoading)
            .overlay(Group {
                if isLoading {
                    ProgressView()
                }
            })
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
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
                    Text("Type: \(order.transactionType)")
                        .font(.subheadline)
                    Text("Amount: \(order.changeAmount)")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("History")
        .onAppear(perform: loadOrderHistory)
        .overlay(Group {
            if isLoading {
                ProgressView()
            }
        })
        .alert(item: $errorMessage) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error), dismissButton: .default(Text("OK")))
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

