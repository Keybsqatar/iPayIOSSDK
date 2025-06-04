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

//public class IPayOrderRepository {
//    let api: IPayOrderAPIProtocol
//    public init(api: IPayOrderAPIProtocol = IPayOrderAPI()) { self.api = api }
//
//    public func placeOrder(
//        otp:   String,
//        transactionId: String
//    ) async throws -> IPayOrderResponse {
//        print("IPayOrderRepository")
//        let req = IPayOrderRequest(
//            otp:   otp,
//            transactionId: transactionId
//        )
//        let resp = try await api.placeOrder(req)
//        print("IPayOrder: \(resp)")
//        return resp
//    }
//}
