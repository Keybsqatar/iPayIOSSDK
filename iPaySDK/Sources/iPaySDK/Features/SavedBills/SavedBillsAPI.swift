import Foundation

public protocol SavedBillsAPIProtocol {
    func getSavedBills(
        mobileNumber: String,
        iPayCustomerID: String
    ) async throws -> SavedBillsResponse
}

public class SavedBillsAPI: SavedBillsAPIProtocol {
    private let client: HTTPClient
    
    public init(client: HTTPClient = .shared) {
        self.client = client
    }
    
    public func getSavedBills(
        mobileNumber: String,
        iPayCustomerID: String
    ) async throws -> SavedBillsResponse {
        try await client.request(
            SavedBillsEndpoint.getSavedBills(
                mobileNumber: mobileNumber,
                iPayCustomerID: iPayCustomerID
            )
        )
    }
}
