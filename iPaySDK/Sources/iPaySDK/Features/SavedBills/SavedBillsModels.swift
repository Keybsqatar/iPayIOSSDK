import Foundation

// Request body
public struct SavedBillsRequest: Encodable {
    public let mobileNumber:    String
    public let iPayCustomerID:  String
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
    public let providerCode:     String
    public let providerName:     String
    public let providerImgUrl:   URL
    public let productSku:       String
    public let productDisplayText: String
    public let serviceCode:      String
    public let amount:           String
    public let currency:         String
}
