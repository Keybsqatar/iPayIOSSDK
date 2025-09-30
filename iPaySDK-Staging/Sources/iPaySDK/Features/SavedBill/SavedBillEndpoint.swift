import Foundation

enum SavedBillEndpoint: Endpoint {
    case get(mobileNumber: String, iPayCustomerID: String, id: String)
    
    var path: String { "api/getSavedBillSDK" }
    var method: HTTPMethod { .post }
    var headers: [String:String]? { ["Content-Type":"application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    
    var body: Data? {
        switch self {
        case let .get(mobile, cust, id):
            let req = SavedBillRequest(
                mobileNumber: mobile,
                iPayCustomerID: cust,
                id: id
            )
            return try? JSONEncoder().encode(req)
        }
    }
}
