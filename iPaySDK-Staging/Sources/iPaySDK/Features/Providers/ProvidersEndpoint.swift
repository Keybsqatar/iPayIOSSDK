import Foundation

enum ProvidersEndpoint: Endpoint {
    case fetch(request: ProvidersRequest)
    var path: String { "api/providers" }
    var method: HTTPMethod { .post }
    var headers: [String:String]? {
        ["Content-Type":"application/json"]
    }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? {
        switch self {
        case .fetch(let req):
            return try? JSONEncoder().encode(req)
        }
    }
}
