//
//  RecordService.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//


import Foundation
import Moya

enum RecordService {
    case getRecords(date: Date, tag: String?)
}

extension RecordService: TargetType {
    var baseURL: URL {
        return URL(string: "https://testflow.simolark.com:8080")!
    }
    
    var path: String {
        return "/records"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case let .getRecords(date, tag):
            var parameters: [String: Any] = [
                "date": formatDate(date)
            ]
            if let tag = tag {
                parameters["tag"] = tag
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String: String]? {
        // 如果需要token验证，在这里添加
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            return [
                "Content-type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        }
        return ["Content-type": "application/json"]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

class RecordManager {
    static let shared = RecordManager()
    private let provider = MoyaProvider<RecordService>()
    
    private init() {}
    
    func getRecords(date: Date, tag: String? = nil, completion: @escaping (Result<[Record], Error>) -> Void) {
        provider.request(.getRecords(date: date, tag: tag)) { result in
            switch result {
            case let .success(response):
                do {
                    let recordResponse = try JSONDecoder().decode(RecordResponse.self, from: response.data)
                    if recordResponse.code == 0 && recordResponse.message == "Success" {
                        completion(.success(recordResponse.data))
                    } else {
                        completion(.failure(NSError(domain: "", code: recordResponse.code, userInfo: [NSLocalizedDescriptionKey: recordResponse.message])))
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
