//
//  FriendsView.swift
//  Moodiary
//
//  Created on 2024/9/17.
//

import SwiftUI

struct FriendsView: View {
    @State private var showFriendsList = false
    @State private var showAddFriendView = false
    @State private var showPostView = false
    
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            backgroundGradient.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                headerView()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("好友关系")
        .sheet(isPresented: $showAddFriendView) {
            AddFriendView(isPresented: $showAddFriendView)
        }
        .sheet(isPresented: $showFriendsList) {
            FriendsListView()
        }
        .sheet(isPresented: $showPostView) {
            PostView(isPresented: $showPostView)
        }
    }
    
    func headerView() -> some View {
        HStack(spacing: 15) {
            headerButton(title: "添加好友", imageName: "person.badge.plus") {
                showAddFriendView = true
            }
            
            headerButton(title: "好友列表", imageName: "person.3") {
                showFriendsList = true
            }
            
            headerButton(title: "发布朋友圈", imageName: "square.and.pencil") {
                showPostView = true
            }
        }
    }
    
    func headerButton(title: String, imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            componentView {
                VStack {
                    Image(systemName: imageName)
                        .font(.system(size: 24))
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    @ViewBuilder
    func componentView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(height: 100)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            content()
        }
    }
}

struct AddFriendView: View {
    @Binding var isPresented: Bool
    @State private var friendEmail = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("输入好友邮箱", text: $friendEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                
                Button(action: addFriend) {
                    Text("添加")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView()
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("添加好友")
            .navigationBarItems(trailing: Button("取消") {
                isPresented = false
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
        }
    }
    
    private func addFriend() {
        isLoading = true
        errorMessage = nil
        
        FriendshipManager.shared.buildRelations(email: friendEmail) { result in
            isLoading = false
            switch result {
            case .success:
                alertTitle = "成功"
                alertMessage = "已成功添加好友"
                showAlert = true
                friendEmail = "" // 清空输入框
            case .failure(let error):
                alertTitle = "错误"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}

struct FriendsListView: View {
    @State private var friends: [Friend] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                List(friends) { friend in
                    FriendRow(friend: friend)
                }
            }
        }
        .navigationTitle("好友列表")
        .onAppear(perform: loadFriends)
    }
    
    private func loadFriends() {
        isLoading = true
        FriendshipManager.shared.listFollowing { result in
            isLoading = false
            switch result {
            case .success(let friends):
                self.friends = friends
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(friend.username)
                    .font(.headline)
                Text(friend.gender)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(friend.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "message")
                .foregroundColor(.blue)
        }
    }
}

struct PostView: View {
    @Binding var isPresented: Bool
    @State private var postContent = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $postContent)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding()
                
                Button("发布") {
                    // 这里添加发布朋友圈的逻辑
                    print("发布朋友圈：\(postContent)")
                    isPresented = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("发布朋友圈")
            .navigationBarItems(trailing: Button("取消") {
                isPresented = false
            })
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendsView()
        }
    }
}
