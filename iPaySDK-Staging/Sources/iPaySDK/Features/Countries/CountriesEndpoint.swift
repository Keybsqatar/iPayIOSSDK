import Foundation

enum CountriesEndpoint: Endpoint {
    case fetch(request: CountriesRequest)
    var path: String { "api/countries" }
    var method: HTTPMethod { .post }
    var headers: [String:String]? { ["Content-Type":"application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? {
        switch self {
        case .fetch(let req):
            return try? JSONEncoder().encode(req)
        }
    }
}
