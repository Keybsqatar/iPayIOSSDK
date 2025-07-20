import Foundation

public struct CheckTransactionRequest: Codable {
    public let transactionReferenceNo: String
}

public struct CheckTransactionResponse: Decodable, Sendable {
    public let status:      String
    public let transaction: CheckTransaction
}

public struct CheckTransaction: Decodable, Sendable {
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
    public let productDisplayText:String
    public let serviceCode:      String
    public let amount:           String
    public let currency:         String
    public let billingRef:       String
    public let status:           String
    public let statusMessage:    String
    public let reciptParams:     String
    public let descriptionMarkdown:     String
    public let readMoreMarkdown:     String
    public let dateTime:         String
}
