import Foundation
import Moya

enum ProductService {
    case getProducts
}

extension ProductService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getProducts:
            return "/products"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getProducts:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getProducts:
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

class ProductManager {
    static let shared = ProductManager()
    private let provider = MoyaProvider<ProductService>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    private init() {}
    
    func getProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        provider.request(.getProducts) { result in
            switch result {
            case let .success(response):
                do {
                    let products = try JSONDecoder().decode([Product].self, from: response.data)
                    completion(.success(products))
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

struct Product: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let pointsCost: Int
    let stock: Int
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id = "productId"
        case name = "productName"
        case description = "productDescription"
        case pointsCost
        case stock
        case imageUrl = "image"
    }
}
