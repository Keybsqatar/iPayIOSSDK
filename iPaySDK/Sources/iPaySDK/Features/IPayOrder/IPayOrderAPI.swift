import Foundation

public protocol IPayOrderAPIProtocol {
    func placeOrder(otp: String, transactionId: String) async throws -> IPayOrderResponse
}

public class IPayOrderAPI: IPayOrderAPIProtocol {
    let client: HTTPClient
    public init(client: HTTPClient = .shared) { self.client = client }
    
    public func placeOrder(
        otp: String,
        transactionId: String
    ) async throws -> IPayOrderResponse {
        try await client.request(IPayOrderEndpoint.order(otp: otp, transactionId: transactionId))
    }
}
