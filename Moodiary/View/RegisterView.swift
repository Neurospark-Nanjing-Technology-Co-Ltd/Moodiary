//
//  RegisterView.swift
//  GuiLai
//
//  Created by YI HE on 2024/10/18.
//


import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create an account")
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
            
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button(action: {
                if validateInputs() {
                    isLoading = true
                    register()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.green)
            .cornerRadius(10)
            .disabled(isLoading)
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
        .navigationBarTitle("Register", displayMode: .inline)
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            showError(message: "All fields are required.")
            return false
        }
        if !email.contains("@") {
            showError(message: "Please enter a valid email address.")
            return false
        }
        if password != confirmPassword {
            showError(message: "Passwords do not match.")
            return false
        }
        return true
    }
    
    private func register() {
        AuthManager.shared.register(email: email, password: password, username: username) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    self.syncUser(email: self.email, username: self.username, password: self.password, token: token)
                    self.showError(message: "Registration successful!")
                    // Here you would typically navigate to the main app view
                case .failure(let error):
                    self.showError(message: "Registration failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func syncUser(email: String, username: String, password: String, token: String) {
        withAnimation {
            let localUser = UserModel(email: email,  password: password, token: token)
            modelContext.insert(localUser)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
