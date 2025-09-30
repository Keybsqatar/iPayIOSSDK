import Foundation

enum ProductsEndpoint: Endpoint {
    case fetch(request: ProductsRequest)
    var path: String { "api/products" }
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
