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
    var id = UUID()
    let username: String
    let gender: String
    let email: String
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
                    let friendListResponse = try JSONDecoder().decode(FriendListResponse.self, from: response.data)
                    completion(.success(friendListResponse.data))
                } catch {
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
