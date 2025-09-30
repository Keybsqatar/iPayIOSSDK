import Foundation

public class SavedBillsRepository {
    private let api: SavedBillsAPIProtocol
    
    public init(api: SavedBillsAPIProtocol = SavedBillsAPI()) {
        self.api = api
    }
    
    /// Returns the array of saved bills (items)
    public func getSavedBills(
        mobileNumber: String,
        iPayCustomerID: String,
        serviceCode: String
    ) async throws -> [SavedBillsItem] {
        let resp = try await api.getSavedBills(
            mobileNumber: mobileNumber,
            iPayCustomerID: iPayCustomerID,
            serviceCode: serviceCode
        )
        return resp.items
    }
}
