import Foundation

public struct ProvidersRequest: Codable {
    public let mobileNumber: String
    public let serviceCode:  String
    public let countryCode:  String
    public let targetNumber:  String?
}

public struct ProviderItem: Identifiable, Decodable, Sendable {
    public var id: UUID = .init()
    
    public let providerCode:  String
    public let countryIso:    String
    public let name:          String
    public let validationRegex:String
    public let logoUrl:       URL
    public let settingDefinitions: [SettingDefinition]
    
    enum CodingKeys: String, CodingKey {
        case providerCode, countryIso, name, validationRegex, logoUrl, settingDefinitions
    }
}

public struct ProvidersResponse: Decodable {
    public let status: String
    public let items:  [ProviderItem]
}
