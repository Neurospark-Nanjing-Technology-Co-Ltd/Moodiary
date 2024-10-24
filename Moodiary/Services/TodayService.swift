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
    case postTodayMood(text: String, emotions: [String: Double])
}

extension TodayService: TargetType {
    var baseURL: URL {
        return URL(string: "https://testflow.simolark.com:8080")!
    }
    
    var path: String {
        switch self {
        case .getTodayMood:
            return "/today/mood"
        case .postTodayMood:
            return "/today/mood"
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
        case let .postTodayMood(text, emotions):
            return .requestParameters(
                parameters: ["text": text, "emotions": emotions],
                encoding: JSONEncoding.default
            )
        }
    }
    
    var headers: [String: String]? {
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            return [
                "Content-type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        }
        return ["Content-type": "application/json"]
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
    
    func postTodayMood(text: String, emotions: [String: Double], completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.postTodayMood(text: text, emotions: emotions)) { result in
            switch result {
            case let .success(response):
                do {
                    let todayMoodResponse = try JSONDecoder().decode(TodayMoodResponse.self, from: response.data)
                    if todayMoodResponse.code == 0 && todayMoodResponse.message == "Success" {
                        completion(.success(()))
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
}

// 这些结构体需要根据实际的API响应格式来定义
struct TodayMoodResponse: Codable {
    let code: Int
    let message: String
    let data: TodayMood
}

struct TodayMood: Codable {
    struct TodayEmotion: Codable {
        let label: String
        let score: Double
    }
    
    let data: [[TodayEmotion]]
    let topEmotion: String
    let comfortLanguage: String
    let behavioralGuidance: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case topEmotion = "top_emotion"
        case comfortLanguage = "comfort_language"
        case behavioralGuidance = "behavioral_guidance"
    }
}
