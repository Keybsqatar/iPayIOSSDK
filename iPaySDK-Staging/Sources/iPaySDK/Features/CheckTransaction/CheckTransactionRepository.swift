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
