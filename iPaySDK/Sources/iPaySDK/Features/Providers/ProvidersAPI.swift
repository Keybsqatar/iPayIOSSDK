import Foundation

public protocol ProvidersAPIProtocol {
    func fetchProviders(request: ProvidersRequest) async throws -> ProvidersResponse
}

public class ProvidersAPI: ProvidersAPIProtocol {
    let client: HTTPClient
    
    public init(client: HTTPClient = .shared) {
        self.client = client
    }
    
    public func fetchProviders(request: ProvidersRequest) async throws -> ProvidersResponse {
        try await client.request(ProvidersEndpoint.fetch(request: request))
    }
}
