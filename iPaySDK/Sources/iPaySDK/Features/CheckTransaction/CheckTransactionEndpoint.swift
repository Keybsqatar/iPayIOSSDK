import Foundation

enum CheckTransactionEndpoint: Endpoint {
    case check(reference: String)
    
    var path: String { "api/checkTransaction" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    
    var body: Data? {
        switch self {
        case .check(let ref):
            let req = CheckTransactionRequest(transactionReferenceNo: ref)
            return try? JSONEncoder().encode(req)
        }
    }
}

//enum CheckTransactionEndpoint: Endpoint {
//    case requestCheckTransaction(CheckTransactionRequest)
//    
//    var path: String { "api/checkTransaction" }
//    var method: HTTPMethod { .post }
//    var headers: [String: String]? { ["Content-Type": "application/json"] }
//    var queryItems: [URLQueryItem]? { nil }
//    var body: Data? {
//        switch self {
//        case .requestCheckTransaction(let req):
//            return try? JSONEncoder().encode(req)
//        }
//    }
//}
