import Foundation

public struct DeleteBillRequest: Encodable {
    public let id: String
}

public struct DeleteBillResponse: Decodable, Sendable {
    public let status:  String
    public let message: String
}
