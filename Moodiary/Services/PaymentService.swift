import Foundation
import Moya

enum PaymentService {
    case createPayment(productId: Int, quantity: Int, addressId: Int)
}

extension PaymentService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .createPayment:
            return "/pay/create"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createPayment:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .createPayment(productId, quantity, addressId):
            return .uploadMultipart([
                MultipartFormData(provider: .data("\(productId)".data(using: .utf8)!), name: "productId"),
                MultipartFormData(provider: .data("\(quantity)".data(using: .utf8)!), name: "quantity"),
                MultipartFormData(provider: .data("\(addressId)".data(using: .utf8)!), name: "addressId")
            ])
        }
    }
    
    var headers: [String: String]? {
        if let token = ModelContextManager.shared.getToken() {
            return [
                "Content-type": "multipart/form-data",
                "Authorization": "\(token)"
            ]
        }
        return nil
    }
}

struct PaymentResponse: Codable {
    let code: Int
    let message: String
    let data: PaymentData?
}

struct PaymentData: Codable {
    let orderId: Int
}

class PaymentManager {
    static let shared = PaymentManager()
    private let provider = MoyaProvider<PaymentService>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    private init() {}
    
    func createPayment(productId: Int, quantity: Int, addressId: Int, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        provider.request(.createPayment(productId: productId, quantity: quantity, addressId: addressId)) { result in
            switch result {
            case .success(let response):
                do {
                    let paymentResponse = try JSONDecoder().decode(PaymentResponse.self, from: response.data)
                    completion(.success(paymentResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
