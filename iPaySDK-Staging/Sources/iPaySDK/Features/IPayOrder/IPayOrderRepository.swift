import Foundation

public class IPayOrderRepository {
    let api: IPayOrderAPIProtocol
    public init(api: IPayOrderAPIProtocol = IPayOrderAPI()) { self.api = api }
    
    /// Calls iPayOrder
    public func placeOrder(
        otp: String,
        transactionId: String
    ) async throws -> IPayOrderResponse {
        try await api.placeOrder(otp: otp, transactionId: transactionId)
    }
}
