import Foundation

public struct IPayOtpRequest: Codable {
    public let mobileNumber:   String
    public let iPayCustomerID: String
    public let targetNumber:   String
    public let serviceCode:    String
    public let productSku:     String
    public let saveRecharge:   String
    public let billAmount:   String
    public let settingsData:   String
}

public struct IPayOtpResponse: Decodable, Sendable {
    public let status:        String
    public let transactionId: Int?
    public let message:       String?
}
