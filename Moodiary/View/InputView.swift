//
//  InputView.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//

import SwiftUI
import Combine

struct InputView: View {
    @Binding var thought: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var isSaving: Bool = false
    let onSave: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if thought.isEmpty {
                        Text(" 现在的想法是...")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 5)
                            .padding(.top, 8)
                    }
                    
                    TextEditor(text: $thought)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .padding(.top, 8)
                
                HStack(spacing: 20) {
                    HStack(spacing: 16) {
                        Button(action: { /* Handle hashtag */ }) {
                            Image(systemName: "number")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { /* Handle image */ }) {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { /* Handle bold */ }) {
                            Text("B")
                                .bold()
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { /* Handle list */ }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { /* Handle more */ }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        guard !thought.isEmpty else { return }
                        isSaving = true
                        onSave(thought)
                    }) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 32, height: 32)
                                .background(Color.blue)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(thought.isEmpty ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        }
                    }
                    .disabled(thought.isEmpty || isSaving)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.bottom, 5)
                .background(Color(UIColor.systemGray6))
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(CustomRoundedCorners(radius: 16, corners: [.topLeft, .topRight]))
            .offset(y: keyboardHeight > 0 ? -keyboardHeight + 8 : 0)
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeOut(duration: 0.25), value: keyboardHeight)
        .onAppear {
            isFocused = true
            setupKeyboardNotifications()
        }
        .onDisappear {
            removeKeyboardNotifications()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// 自定义圆角形状
struct CustomRoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
