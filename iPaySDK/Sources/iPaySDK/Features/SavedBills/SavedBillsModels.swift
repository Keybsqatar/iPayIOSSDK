import Foundation

// Request body
public struct SavedBillsRequest: Encodable {
    public let mobileNumber:    String
    public let iPayCustomerID:  String
    public let serviceCode:     String
}

// Top-level response
public struct SavedBillsResponse: Decodable {
    public let status: String
    public let items:  [SavedBillsItem]
}

// One saved-bill entry
public struct SavedBillsItem: Identifiable, Decodable, Sendable {
    public let id:               String
    public let mobileNumber:     String
    public let iPayCustomerID:   String
    public let targetIdentifier: String
    public let countryIso2:      String
    public let countryIso3:      String
    public let countryName:      String
    public let countryFlagUrl:   URL
    public let countryPrefix:      String?
    public let countryMinimumLength:      String?
    public let countryMaximumLength:      String?
    public let providerCode:     String
    public let providerName:     String
    public let providerImgUrl:   URL
    public let productSku:       String
    public let productDisplayText: String
    public let providerValidationRegex:       String?
    public let serviceCode:      String
    public let amount:           String
    public let currency:         String
    public let dateTime:         String
    public let billingRef:       String?
    public let reciptParams:     String?
    public let settingsData:     String?
}
