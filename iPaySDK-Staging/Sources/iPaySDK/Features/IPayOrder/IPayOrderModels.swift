import Foundation

public struct IPayOrderRequest: Codable {
    public let otp:           String
    public let transactionId: String
}

public struct IPayOrderResponse: Decodable, Sendable {
    public let status:                String
    public let transactionReference:  String?
    public let message:               String?
}
