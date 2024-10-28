//
//  PostResponse.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/28.
//


import Foundation
import Moya

// MARK: - Post Service
enum PostService {
    case getPosts(page: Int, pageSize: Int)
}

extension PostService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "/post/check"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case let .getPosts(page, pageSize):
            let parameters = [
                "page": page,
                "pageSize": pageSize
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        if let token = ModelContextManager.shared.getToken() {
            headers["Authorization"] = token
        }
        return headers
    }
}

// MARK: - Post Manager
class PostManager {
    static let shared = PostManager()
    private let provider = MoyaProvider<PostService>()
    
    private init() {}
    
    func getPosts(page: Int = 1, pageSize: Int = 10, completion: @escaping (Result<[Post], Error>) -> Void) {
        provider.request(.getPosts(page: page, pageSize: pageSize)) { result in
            switch result {
            case let .success(response):
                do {
                    let postResponse = try JSONDecoder().decode(PostResponse.self, from: response.data)
                    if postResponse.code == 0 {
                        completion(.success(postResponse.data.rows))
                    } else {
                        completion(.failure(NSError(domain: "", code: postResponse.code, userInfo: [NSLocalizedDescriptionKey: postResponse.message])))
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
