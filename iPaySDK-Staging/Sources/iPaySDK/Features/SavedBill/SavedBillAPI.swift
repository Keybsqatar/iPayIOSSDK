import Foundation

public protocol SavedBillAPIProtocol {
    func fetchSavedBill(
        mobileNumber: String,
        iPayCustomerID: String,
        id: String
    ) async throws -> SavedBillResponse
}

public class SavedBillAPI: SavedBillAPIProtocol {
    let client: HTTPClient
    public init(client: HTTPClient = .shared) { self.client = client }
    
    public func fetchSavedBill(
        mobileNumber: String,
        iPayCustomerID: String,
        id: String
    ) async throws -> SavedBillResponse {
        try await client.request(
            SavedBillEndpoint.get(
                mobileNumber: mobileNumber,
                iPayCustomerID: iPayCustomerID,
                id: id
            )
        )
    }
}
