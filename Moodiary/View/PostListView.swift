//
//  PostListView.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/28.
//
import SwiftUI

struct PostListView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        PostCard(post: post)
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: loadPosts)
    }
    
    private func loadPosts() {
        isLoading = true
        PostManager.shared.getPosts() { result in
            isLoading = false
            switch result {
            case .success(let posts):
                self.posts = posts
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Post Card View
struct PostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text(post.username)
                    .font(.headline)
                
                Spacer()
                
                Text(formatDate(post.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Emotions View (matching RecordCard)
            EmotionSpectrum(emotions: parseMoodJson(post.mood))
                .frame(height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // Content Preview (matching RecordCard)
            Text(post.content)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
    
    private func parseMoodJson(_ jsonString: String) -> [MoodLabel] {
        // Remove square brackets and split by commas
        let cleanString = jsonString.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let items = cleanString.components(separatedBy: "}, {")
        
        return items.compactMap { item -> MoodLabel? in
            // Extract label and score using string manipulation
            let cleanItem = item.replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
            
            let parts = cleanItem.components(separatedBy: ",")
            guard parts.count == 2 else { return nil }
            
            let labelPart = parts[0].components(separatedBy: ":")[1]
            let scorePart = parts[1].components(separatedBy: ":")[1]
            
            let label = labelPart.trimmingCharacters(in: CharacterSet(charactersIn: "' "))
            guard let score = Double(scorePart.trimmingCharacters(in: .whitespaces)) else { return nil }
            
            return MoodLabel(label: label, score: score)
        }
    }
}
