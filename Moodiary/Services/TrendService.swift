//
//  TrendService.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import Moya
import Foundation

enum TrendService {
    case getTrends(period: TrendPeriod)
}

enum TrendPeriod: String {
    case week = "week"
    case month = "month"
}

extension TrendService: TargetType {
    var baseURL: URL {
        return URL(string: "https://testflow.simolark.com:8080")!
    }
    
    var path: String {
        return "/trends"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getTrends(let period):
            return .requestParameters(
                parameters: ["period": period.rawValue],
                encoding: URLEncoding.default
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

// MARK: - Manager
class TrendManager {
    static let shared = TrendManager()
    private let provider = MoyaProvider<TrendService>()
    
    private init() {}
    
    func getTrends(period: TrendPeriod, completion: @escaping (Result<TrendData, Error>) -> Void) {
        provider.request(.getTrends(period: period)) { result in
            switch result {
            case let .success(response):
                do {
                    let trendResponse = try JSONDecoder().decode(TrendResponse.self, from: response.data)
                    if trendResponse.code == 0 && trendResponse.message == "Success" {
                        completion(.success(trendResponse.data))
                    } else {
                        completion(.failure(NSError(domain: "", code: trendResponse.code, userInfo: [NSLocalizedDescriptionKey: trendResponse.message])))
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
