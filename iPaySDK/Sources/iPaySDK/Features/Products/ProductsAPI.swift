import Foundation

public protocol ProductsAPIProtocol {
    func fetchProducts(request: ProductsRequest) async throws -> ProductsResponse
}

public class ProductsAPI: ProductsAPIProtocol {
    let client: HTTPClient
    
    public init(client: HTTPClient = .shared) { self.client = client }
    
    public func fetchProducts(request: ProductsRequest) async throws ->
    ProductsResponse {
        try await client.request(ProductsEndpoint.fetch(request: request))
    }
}
