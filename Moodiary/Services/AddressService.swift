import Foundation
import Moya

enum AddressService {
    case getAddresses
}

extension AddressService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getAddresses:
            return "/Address/adresses"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAddresses:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAddresses:
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

class AddressManager {
    static let shared = AddressManager()
    private let provider = MoyaProvider<AddressService>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    private init() {}
    
    func getAddresses(completion: @escaping (Result<AddressResponse, Error>) -> Void) {
        provider.request(.getAddresses) { result in
            switch result {
            case let .success(response):
                do {
                    let addressResponse = try JSONDecoder().decode(AddressResponse.self, from: response.data)
                    if addressResponse.code == 0 && addressResponse.message == "Success" {
                        completion(.success(addressResponse))
                    } else {
                        completion(.failure(NSError(domain: "", code: addressResponse.code, userInfo: [NSLocalizedDescriptionKey: addressResponse.message])))
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
struct AddressResponse: Codable {
    let code: Int
    let message: String
    let data: [Address]
}

struct Address: Codable, Identifiable {
    let id: Int
    let userId: Int
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case id = "addressId"
        case userId, street, city, state, postalCode, country
    }
}
