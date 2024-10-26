//
//  ModelContextManager.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/26.
//
import SwiftUI
import SwiftData

class ModelContextManager {
    static let shared = ModelContextManager()
    var modelContext: ModelContext?
    
    private init() {}
    
    func getToken() -> String? {
        guard let context = modelContext else {
            print("ModelContext is nil")
            return nil
        }
        
        let descriptor = FetchDescriptor<UserModel>()
        do {
            let user = try context.fetch(descriptor).first
            // 添加打印来确认 token 获取
            print("Retrieved token: \(user?.token ?? "no token")")
            return user?.token
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
    func clearUserData() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<UserModel>()
        if let users = try? context.fetch(descriptor) {
            users.forEach { context.delete($0) }
            try? context.save()
        }
    }
}
