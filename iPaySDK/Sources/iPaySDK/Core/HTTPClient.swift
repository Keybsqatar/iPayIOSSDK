import Foundation

public final class HTTPClient {
    public static let shared = HTTPClient()
    private init() {}
    
    private static let defaultBaseURL = URL(string: "http://keybs.ai/")!
    //    private static let defaultBaseURL = URL(string: "http://192.168.1.100/")!
    private let baseURL: URL = HTTPClient.defaultBaseURL
    private var secretKey: String?
    
    /// Call this once with the host‐app’s token
    public func initialize(secretKey: String) {
        self.secretKey = secretKey
    }
    
    public func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T {
        // Build URLComponents
        guard var comps = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        comps.queryItems = endpoint.queryItems
        guard let url = comps.url else {
            throw NetworkError.invalidURL
        }
        
        // Build URLRequest
        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method.rawValue
        req.httpBody   = endpoint.body
        // fixed header
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // secret‐key header
        if let token = secretKey {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        endpoint.headers?.forEach {
            req.setValue($1, forHTTPHeaderField: $0)
        }
        
        // Perform
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
    //     print("HTTPClient http.statusCode \(http.statusCode) \(url)")
    //    print("HTTPClient req.httpBody \(String(data: req.httpBody ?? Data(), encoding: .utf8) ?? "")")
    //    print("HTTPClient response \(String(data: data, encoding: .utf8) ?? "")")
        
        if 200..<300 ~= http.statusCode {
            return try decoder.decode(T.self, from: data)
        } else {
            let apiErr = (try? decoder.decode(ApiError.self, from: data))
            ??
            ApiError(status: http.statusCode,
                     error: nil, message: nil, messages: nil)
            
            print("HTTPClient apiErr \(apiErr)")
            
            throw NetworkError.apiError(code: http.statusCode, error: apiErr)
        }
    }
}
