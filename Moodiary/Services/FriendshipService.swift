import Foundation
import Moya

enum FriendshipService {
    case listFollowing
}

extension FriendshipService: TargetType {
    var baseURL: URL { return URL(string: "http://54.255.253.1:8080")! }
    
    var path: String {
        switch self {
        case .listFollowing:
            return "/friendship/listFollowing"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .listFollowing:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .listFollowing:
            return .requestPlain
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
    let id = UUID()
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
}
