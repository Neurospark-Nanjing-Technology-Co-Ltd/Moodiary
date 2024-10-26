//
//  RecordService.swift
//  MooDairy
//
//  Created by YI HE on 2024/10/22.
//


import Foundation
import Moya
import SwiftData
import SwiftUI


enum RecordService {
    case getRecords(date: Date, tag: String?)
    case createRecord(content: String, title: String)
}

extension RecordService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getRecords:
            return "/Record/History"
        case .createRecord:
            return "/Record/add"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getRecords:
            return .get
        case .createRecord:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .getRecords(date, tag):
            var formData: [MultipartFormData] = [
                MultipartFormData(provider: .data(formatDate(date).data(using: .utf8)!), name: "date")
            ]
            
            if let tag = tag {
                formData.append(MultipartFormData(provider: .data(tag.data(using: .utf8)!), name: "tag"))
            }
            
            return .uploadMultipart(formData)
            
        case let .createRecord(content, title):
            let formData: [MultipartFormData] = [
                MultipartFormData(provider: .data(content.data(using: .utf8)!), name: "content"),
                MultipartFormData(provider: .data(title.data(using: .utf8)!), name: "title")
            ]
            return .uploadMultipart(formData)
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        
        if let token = ModelContextManager.shared.getToken() {
            headers["Authorization"] = token
        }
        
        return headers
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
                    print("Decoding error: \(error)")  // 添加更详细的错误日志
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func createRecord(content: String, title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.createRecord(content: content, title: title)) { result in
            switch result {
            case let .success(response):
                do {
                    let recordResponse = try JSONDecoder().decode(BaseResponse.self, from: response.data)
                    if recordResponse.code == 0 && recordResponse.message == "Success" {
                        completion(.success(()))
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

struct BaseResponse: Codable {
    let code: Int
    let message: String
}
