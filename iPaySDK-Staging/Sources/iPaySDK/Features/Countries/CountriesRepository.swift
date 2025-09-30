import Foundation

public final class CountriesRepository {
    private let api: CountriesAPIProtocol
    public init(api: CountriesAPIProtocol = CountriesAPI()) { self.api = api }
    
    public func getCountries(
        mobileNumber: String,
        serviceCode:  String
    ) async throws -> [CountryItem] {
        //        print("CountriesRepository getCountries")
        let req  = CountriesRequest(
            mobileNumber: mobileNumber,
            serviceCode:  serviceCode
        )
        let resp = try await api.fetchCountries(request: req)
        //        print("Countries: \(resp)")
        return resp.items
    }
}
