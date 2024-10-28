//
//  PostResponse.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/28.
//
import Foundation

struct PostResponse: Codable {
    let code: Int
    let message: String
    let data: PostData
}

struct PostData: Codable {
    let total: Int
    let rows: [Post]
}

struct Post: Codable, Identifiable {
    let postId: Int
    let recordId: Int
    let userId: Int
    let username: String
    let email: String
    let title: String
    let content: String
    let mood: String
    let createdAt: String
    let updatedAt: String
    let topEmotion: String
    let comfortLanguage: String
    let behavioralGuidance: String
    
    var id: Int { postId }
}
