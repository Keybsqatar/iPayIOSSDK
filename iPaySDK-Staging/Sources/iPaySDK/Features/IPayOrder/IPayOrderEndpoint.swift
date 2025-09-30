import Foundation

enum IPayOrderEndpoint: Endpoint {
    case order(otp: String, transactionId: String)
    
    var path: String { "api/iPayOrder" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    
    var body: Data? {
        switch self {
        case .order(let otp, let txId):
            let req = IPayOrderRequest(otp: otp, transactionId: txId)
            return try? JSONEncoder().encode(req)
        }
    }
}
