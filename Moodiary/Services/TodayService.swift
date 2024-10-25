//
//  TodayService.swift
//  Moodiary
//
//  Created by F1reC on 2024/10/23.
//

import Foundation
import Moya

enum TodayService {
    case getTodayMood
    case postTodayMood(content: String)
}

extension TodayService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getTodayMood:
            return "/Record/latest"
        case .postTodayMood:
            return "/Record/add"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTodayMood:
            return .get
        case .postTodayMood:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getTodayMood:
            return .requestPlain
        case let .postTodayMood(content):
            return .requestParameters(
                parameters: ["content": content, "title": "1"],
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String: String]? {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsiaWQiOjgsImVtYWlsIjoiMTQ4OTQ3Mjk4OUBxcS5jb20ifSwiZXhwIjoxNzI5OTEzMTAzfQ.Ys7hoRxFu_D7UEJtnWVWvOHc5jvX-uL0iyCvJO25aQI"
        return [
            "Content-type": "application/x-www-form-urlencoded",
            "Authorization": "Bearer \(token)"
        ]
    }
}

class TodayManager {
    static let shared = TodayManager()
    private let provider = MoyaProvider<TodayService>()
    
    private init() {}
    
    func getTodayMood(completion: @escaping (Result<TodayMood, Error>) -> Void) {
        provider.request(.getTodayMood) { result in
            switch result {
            case let .success(response):
                do {
                    let todayMoodResponse = try JSONDecoder().decode(TodayMoodResponse.self, from: response.data)
                    if todayMoodResponse.code == 0 && todayMoodResponse.message == "Success" {
                        completion(.success(todayMoodResponse.data))
                    } else {
                        completion(.failure(NSError(domain: "", code: todayMoodResponse.code, userInfo: [NSLocalizedDescriptionKey: todayMoodResponse.message])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func postTodayMood(content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.postTodayMood(content: content)) { [weak self] result in
            switch result {
            case .success(_):
                self?.getTodayMood { latestResult in
                    switch latestResult {
                    case .success(let latestMood):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// 这些结构体需要根据实际的API响应格式来定义
struct TodayMoodResponse: Codable {
    let code: Int
    let message: String
    let data: TodayMood
}

struct TodayMood: Codable {
    let recordId: Int
    let userId: Int
    let content: String
    let mood: String?
    let moodJson: String?
    let topEmotion: String?
    let comfortLanguage: String?
    let behavioralGuidance: String?
    let createdAt: String
    let updatedAt: String
}
