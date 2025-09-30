import Foundation

enum DeleteBillEndpoint: Endpoint {
    case delete(id: String)
    
    var path: String { "api/deleteBillSDK" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { ["Content-Type":"application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    
    var body: Data? {
        switch self {
        case .delete(let id):
            let req = DeleteBillRequest(id: id)
            return try? JSONEncoder().encode(req)
        }
    }
}
