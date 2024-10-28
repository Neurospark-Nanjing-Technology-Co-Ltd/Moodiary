//
//  SettingsView.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI

struct SettingsView: View {
    let backgroundGradient = LinearGradient(gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]), startPoint: .top, endPoint: .bottom)
    let cardGradient = LinearGradient(gradient: Gradient(colors: [Color.white, Color(hex: "F8F9FA")]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(settingsOptions, id: \.title) { option in
                            NavigationLink(destination: option.destination) {
                                SettingsRow(imageName: option.imageName, title: option.title)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("记录心情的色彩")
        }
    }
    
    private var settingsOptions: [(imageName: String, title: String, destination: AnyView)] {
        [
            ("person.circle", "Acount", AnyView(AccountSettingsView())),
            ("person.2", "Friends", AnyView(FriendsView())),
            ("cart", "Mall", AnyView(StoreView())),
            ("globe", "Language", AnyView(LanguageSettingsView())),
            ("doc.text", "User Agreement", AnyView(UserAgreementView()))
        ]
    }
}

struct SettingsRow: View {
    let imageName: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AccountSettingsView: View {
    var body: some View {
        Text("账户设置")
            .navigationTitle("账户")
    }
}



struct LanguageSettingsView: View {
    var body: some View {
        Text("语言设置")
            .navigationTitle("多语言")
    }
}

struct UserAgreementView: View {
    var body: some View {
        Text("用户协议内容")
            .navigationTitle("用户协议")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
