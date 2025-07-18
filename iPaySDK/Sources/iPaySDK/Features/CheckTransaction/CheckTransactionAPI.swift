import Foundation

public protocol CheckTransactionAPIProtocol {
    func check(reference: String) async throws -> CheckTransactionResponse
}

public class CheckTransactionAPI: CheckTransactionAPIProtocol {
    let client: HTTPClient
    public init(client: HTTPClient = .shared) { self.client = client }
    
    public func check(
        reference: String
    ) async throws -> CheckTransactionResponse {
        try await client.request(CheckTransactionEndpoint.check(reference: reference))
    }
}

//public protocol CheckTransactionAPIProtocol {
//    func placeCheckTransaction(_ request: CheckTransactionRequest) async throws -> CheckTransactionResponse
//}
//
//public class CheckTransactionAPI: CheckTransactionAPIProtocol {
//    let client: HTTPClient
//    
//    public init(client: HTTPClient = .shared) { self.client = client }
//    
//    public func placeCheckTransaction(_ request: CheckTransactionRequest) async throws -> CheckTransactionResponse {
//        try await client.request(CheckTransactionEndpoint.requestCheckTransaction(request))
//    }
//}
