import Foundation

public class SavedBillRepository {
    let api: SavedBillAPIProtocol
    public init(api: SavedBillAPIProtocol = SavedBillAPI()) {
        self.api = api
    }
    
    /// Returns the single SavedBillItem (or throws if none)
    public func getSavedBill(
        mobileNumber: String,
        iPayCustomerID: String,
        id: String
    ) async throws -> SavedBillItem {
        let resp = try await api.fetchSavedBill(
            mobileNumber: mobileNumber,
            iPayCustomerID: iPayCustomerID,
            id: id
        )
        guard let first = resp.items.first else {
            throw NetworkError.apiError(
                code: 404,
                error: ApiError(
                    status: 404,
                    error: nil,
                    message: "Saved bill not found",
                    messages: nil
                )
            )
        }
        return first
    }
}
