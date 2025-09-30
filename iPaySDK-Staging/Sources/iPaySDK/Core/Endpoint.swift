import Foundation

public enum HTTPMethod: String {
  case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

/// Blueprint for any API call
public protocol Endpoint {
  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String]? { get }
  var queryItems: [URLQueryItem]? { get }
  var body: Data? { get }
}
