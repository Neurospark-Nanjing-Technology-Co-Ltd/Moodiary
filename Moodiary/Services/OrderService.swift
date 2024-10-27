import Foundation
import Moya

enum OrderService {
    case getOrderHistory
}

extension OrderService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getOrderHistory:
            return "/transaction/history"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getOrderHistory:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getOrderHistory:
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

class OrderManager {
    static let shared = OrderManager()
    private let provider = MoyaProvider<OrderService>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    private init() {}
    
    func getOrderHistory(completion: @escaping (Result<OrderHistoryResponse, Error>) -> Void) {
        provider.request(.getOrderHistory) { result in
            switch result {
            case let .success(response):
                do {
                    let orderHistoryResponse = try JSONDecoder().decode(OrderHistoryResponse.self, from: response.data)
                    if orderHistoryResponse.code == 0 && orderHistoryResponse.message == "Success" {
                        completion(.success(orderHistoryResponse))
                    } else {
                        completion(.failure(NSError(domain: "", code: orderHistoryResponse.code, userInfo: [NSLocalizedDescriptionKey: orderHistoryResponse.message])))
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
struct OrderHistoryResponse: Codable {
    let code: Int
    let message: String
    let data: OrderHistoryData
}

struct OrderHistoryData: Codable {
    let total: Int
    let rows: [TransactionRecord]
}

struct TransactionRecord: Codable, Identifiable {
    let transactionId: Int
    let userId: Int
    let changeAmount: Int
    let transactionType: String
    let description: String
    
    var id: Int { transactionId }
}
