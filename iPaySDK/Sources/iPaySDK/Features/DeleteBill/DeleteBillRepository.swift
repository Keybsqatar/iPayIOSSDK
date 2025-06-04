import Foundation

public class DeleteBillRepository {
    let api: DeleteBillAPIProtocol
    public init(api: DeleteBillAPIProtocol = DeleteBillAPI()) {
        self.api = api
    }
    
    /// Delete a saved-bill by its id.
    public func deleteBill(id: String) async throws -> DeleteBillResponse {
        try await api.deleteBill(id: id)
    }
}
