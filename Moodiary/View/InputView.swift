//
//  InputView.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

struct InputView: View {
    @Binding var thought: String
    @Binding var isPresented: Bool
    @State private var tempThought: String = ""
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $tempThought)
                    .padding()
                    .frame(minHeight: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding()
            }
            .navigationBarTitle("输入你的随想", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                },
                trailing: Button("保存") {
                    thought = tempThought
                    onSave()
                    isPresented = false
                }
            )
        }
        .onAppear {
            tempThought = thought
        }
    }
}

