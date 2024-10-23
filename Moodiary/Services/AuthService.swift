//
//  AuthService.swift
//  GuiLai
//
//  Created by YI HE on 2024/10/18.
//


import Foundation
import Moya

enum AuthService {
    case login(email: String, password: String)
    case register(email: String, password: String, username: String)
}

extension AuthService: TargetType {
    var baseURL: URL {
        return URL(string: "https://testflow.simolark.com:8080")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .register:
            return "/users/register"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .register:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .login(email, password):
            let formData: [MultipartFormData] = [
                MultipartFormData(provider: .data(email.data(using: .utf8)!), name: "email"),
                MultipartFormData(provider: .data(password.data(using: .utf8)!), name: "password")
            ]
            return .uploadMultipart(formData)
        case let .register(email, password, username):
            let formData: [MultipartFormData] = [
                MultipartFormData(provider: .data(email.data(using: .utf8)!), name: "email"),
                MultipartFormData(provider: .data(password.data(using: .utf8)!), name: "password"),
                MultipartFormData(provider: .data(username.data(using: .utf8)!), name: "username")
            ]
            return .uploadMultipart(formData)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "multipart/form-data"]
    }
}

class AuthManager {
    static let shared = AuthManager()
    private let provider = MoyaProvider<AuthService>()
    
    private init() {}
    
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.login(email: email, password: password)) { result in
            switch result {
            case let .success(response):
                do {
                    if let json = try response.mapJSON() as? [String: Any],
                       let code = json["code"] as? Int,
                       let message = json["message"] as? String {
                        if code == 0 && message == "Success" {
                            if let tokenData = json["data"] as? String {
                                completion(.success(tokenData))
                            } else {
                                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid token data"])))
                            }
                        } else {
                            completion(.failure(NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: message])))
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func register(email: String, password: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.register(email: email, password: password, username: username)) { result in
            switch result {
            case let .success(response):
                do {
                    if let json = try response.mapJSON() as? [String: Any],
                       let code = json["code"] as? Int,
                       let message = json["message"] as? String {
                        if code == 0 && message == "Success" {
                            if let tokenData = json["data"] as? String {
                                completion(.success(tokenData))
                            } else {
                                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid token data"])))
                            }
                        } else {
                            completion(.failure(NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: message])))
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
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
