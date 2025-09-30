import Foundation

public protocol DeleteBillAPIProtocol {
    func deleteBill(id: String) async throws -> DeleteBillResponse
}

public class DeleteBillAPI: DeleteBillAPIProtocol {
    let client: HTTPClient
    public init(client: HTTPClient = .shared) {
        self.client = client
    }
    
    public func deleteBill(id: String) async throws -> DeleteBillResponse {
        try await client.request(
            DeleteBillEndpoint.delete(id: id)
        )
    }
}
