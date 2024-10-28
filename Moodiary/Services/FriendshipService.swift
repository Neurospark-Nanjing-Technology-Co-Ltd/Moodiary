import Foundation
import Moya

enum FriendshipService {
    case listFollowing
    case buildRelations(email: String)
}

extension FriendshipService: TargetType {
    var baseURL: URL { return URL(string: "http://54.255.253.1:8080")! }
    
    var path: String {
        switch self {
        case .listFollowing:
            return "/friendship/listFollowing"
        case .buildRelations:
            return "/friendship/BuildRelations"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .listFollowing:
            return .get
        case .buildRelations:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .listFollowing:
            return .requestPlain
        case .buildRelations(let email):
            let formData = MultipartFormData(provider: .data(email.data(using: .utf8)!), name: "email")
            return .uploadMultipart([formData])
        }
    }
    
    var headers: [String: String]? {
        if let token = ModelContextManager.shared.getToken() {
            return ["Authorization": token]
        }
        return nil
    }
}

struct Friend: Codable, Identifiable {
    let id = UUID()  // 本地使用的 ID
    let username: String
    let gender: String
    let email: String
    let password: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case username, gender, email, password, status
    }
}

struct FriendListResponse: Codable {
    let code: Int
    let message: String
    let data: [Friend]
}

class FriendshipManager {
    static let shared = FriendshipManager()
    private let provider = MoyaProvider<FriendshipService>()
    
    private init() {}
    
    func listFollowing(completion: @escaping (Result<[Friend], Error>) -> Void) {
        provider.request(.listFollowing) { result in
            switch result {
            case .success(let response):
                do {
                    // 添加调试信息
                    print("Response data: \(String(data: response.data, encoding: .utf8) ?? "Unable to decode")")
                    
                    let friendListResponse = try JSONDecoder().decode(FriendListResponse.self, from: response.data)
                    if friendListResponse.code == 0 {
                        completion(.success(friendListResponse.data))
                    } else {
                        let error = NSError(domain: "", code: friendListResponse.code, userInfo: [NSLocalizedDescriptionKey: friendListResponse.message])
                        completion(.failure(error))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func buildRelations(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.buildRelations(email: email)) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "添加好友失败"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
