import Foundation

public protocol CountriesAPIProtocol {
    func fetchCountries(request: CountriesRequest) async throws -> CountriesResponse
}

public final class CountriesAPI: CountriesAPIProtocol {
    private let client: HTTPClient
    
    public init(client: HTTPClient = .shared) { self.client = client }
    
    public func fetchCountries(request: CountriesRequest) async throws ->
    CountriesResponse {
        try await client.request(CountriesEndpoint.fetch(request: request))
    }
}
