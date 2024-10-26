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
}

extension TodayService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getTodayMood:
            return "/Record/latest"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTodayMood:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getTodayMood:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        if let token = ModelContextManager.shared.getToken() {
            return [
                "Content-type": "application/x-www-form-urlencoded",
                "Authorization": "\(token)"
            ]
        }
        return nil
    }
}

class TodayManager {
    static let shared = TodayManager()
    private let provider = MoyaProvider<TodayService>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
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
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// 响应模型
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
    let moodJson: [MoodLabel]?  // 改为直接使用 [MoodLabel] 类型
    let topEmotion: String?
    let comfortLanguage: String?
    let behavioralGuidance: String?
    let createdAt: String
    let updatedAt: String
}

