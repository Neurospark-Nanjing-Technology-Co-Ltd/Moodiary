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
            }
            .padding()
            .navigationTitle("添加好友")
            .navigationBarItems(trailing: Button("取消") {
                isPresented = false
            })
        }
    }
    
    private func addFriend() {
        // 这里添加处理添加好友的逻辑
        print("添加好友：\(friendEmail)")
        friendEmail = "" // 清空输入框
        isPresented = false // 关闭添加好友视图
    }
}

struct FriendsListView: View {
    var body: some View {
        List {
            ForEach(0..<5) { _ in
                FriendRow()
            }
        }
        .navigationTitle("好友列表")
    }
}

struct FriendRow: View {
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("好友名称")
                    .font(.headline)
                Text("好友状态")
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
