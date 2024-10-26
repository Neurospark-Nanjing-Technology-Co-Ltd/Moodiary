//
//  LoginView.swift
//  GuiLai
//
//  Created by YI HE on 2024/9/11.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isLoggedIn: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to MooDairy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button(action: {
                    if validateInputs() {
                        isLoading = true
                        login()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading)
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty || password.isEmpty {
            showError(message: "Email and password are required.")
            return false
        }
        if !email.contains("@") {
            showError(message: "Please enter a valid email address.")
            return false
        }
        return true
    }
    
    private func login() {
        AuthManager.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    self.syncUser(email: self.email, password: self.password, token: token)
                    self.isLoggedIn = true  // 立即更新登录状态
                case .failure(let error):
                    self.showError(message: "Login failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func syncUser(email: String, password: String, token: String) {
        let localUser = UserModel(email: email, password: password, token: token)
        modelContext.insert(localUser)
        do {
            try modelContext.save()
            ModelContextManager.shared.modelContext = modelContext
            // 添加打印来确认 token 已保存
            print("Token saved: \(token)")
        } catch {
            print("Failed to save user: \(error)")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
