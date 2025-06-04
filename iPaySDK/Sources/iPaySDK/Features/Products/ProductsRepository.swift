import Foundation

public final class ProductsRepository {
    let api: ProductsAPIProtocol
    public init(api: ProductsAPIProtocol = ProductsAPI()) { self.api = api }
    
    public func getProducts(
        mobileNumber: String,
        serviceCode:  String,
        countryCode:  String,
        providerCode: String
    ) async throws -> [ProductItem] {
        // print("ProductsRepository getProducts")
        let req  = ProductsRequest(
            mobileNumber: mobileNumber,
            serviceCode:  serviceCode,
            countryCode:  countryCode,
            providerCode: providerCode
        )
        let resp = try await api.fetchProducts(request: req)
        // print("Products: \(resp)")
        return resp.items
    }
}
