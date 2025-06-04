import Foundation

public class CheckTransactionRepository {
    let api: CheckTransactionAPIProtocol
    public init(api: CheckTransactionAPIProtocol = CheckTransactionAPI()) {
        self.api = api
    }
    
    /// Calls checkTransaction
    public func checkTransaction(
        reference: String
    ) async throws -> CheckTransactionResponse {
        try await api.check(reference: reference)
    }
}

//public class CheckTransactionRepository {
//    let api: CheckTransactionAPIProtocol
//    public init(api: CheckTransactionAPIProtocol = CheckTransactionAPI()) { self.api = api }
//
//    public func placeCheckTransaction(
//        reference: String
//    ) async throws -> CheckTransactionResponse {
//        print("CheckTransactionRepository")
//        let req = CheckTransactionRequest(
//            transactionReferenceNo:   reference
//        )
//        let resp = try await api.placeCheckTransaction(req)
//        print("CheckTransaction: \(resp)")
//        return resp
//    }
//}
