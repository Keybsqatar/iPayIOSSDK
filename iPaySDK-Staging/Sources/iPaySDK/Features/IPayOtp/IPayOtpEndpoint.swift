import Foundation

enum IPayOtpEndpoint: Endpoint {
    case requestOtp(IPayOtpRequest)
    
    var path: String { "api/requestiPayOtp" }
    var method: HTTPMethod { .post }
    var headers: [String:String]? { ["Content-Type":"application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? {
        switch self {
        case .requestOtp(let req):
            return try? JSONEncoder().encode(req)
        }
    }
}
