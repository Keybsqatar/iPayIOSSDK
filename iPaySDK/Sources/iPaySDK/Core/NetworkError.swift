import Foundation

public enum NetworkError: Error, Sendable {
  case invalidURL
  case invalidResponse
  case apiError(code: Int, error: ApiError)
  case decodingError(Error)
  case underlying(Error)
}
