import Foundation

public class ProvidersRepository {
    let api: ProvidersAPIProtocol
    public init(api: ProvidersAPIProtocol = ProvidersAPI()) { self.api = api }

    public func getProviders(
        mobileNumber: String,
        serviceCode:  String,
        countryCode:  String
    ) async throws -> [ProviderItem] {
        // print("ProvidersRepository getProviders")
        let req  = ProvidersRequest(
            mobileNumber: mobileNumber,
            serviceCode:  serviceCode,
            countryCode:  countryCode
        )
        let resp = try await api.fetchProviders(request: req)
//        print("Providers: \(resp.items)")
        return resp.items
    }
}
