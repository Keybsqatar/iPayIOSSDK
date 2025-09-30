import Foundation

enum SavedBillsEndpoint: Endpoint {
    case getSavedBills(mobileNumber: String, iPayCustomerID: String, serviceCode: String)
    
    var path: String { "api/getSavedBillsSDK" }
    var method: HTTPMethod { .post }
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String:String]? { ["Content-Type":"application/json"] }
    
    var body: Data? {
        switch self {
        case let .getSavedBills(mobile, customer, serviceCode):
            let req = SavedBillsRequest(
                mobileNumber: mobile,
                iPayCustomerID: customer,
                serviceCode: serviceCode
            )
            return try? JSONEncoder().encode(req)
        }
    }
}
