import Foundation

public struct CountriesRequest: Codable {
    public let mobileNumber: String
    public let serviceCode:  String
}

public struct CountryItem: Identifiable, Codable, Sendable {
    public var id: UUID = .init()
    
    public let countryIso:    String
    public let name:          String
    public let prefix:        String
    public let minimumLength: String
    public let maximumLength: String
    public let flagUrl:       URL
    
    enum CodingKeys: String, CodingKey {
        case countryIso, name, prefix, minimumLength, maximumLength, flagUrl
    }
}

public struct CountriesResponse: Codable {
    public let status: String
    public let items:  [CountryItem]
}
