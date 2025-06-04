import Foundation

public protocol IPayOtpAPIProtocol {
    func requestOtp(_ request: IPayOtpRequest) async throws -> IPayOtpResponse
}

public class IPayOtpAPI: IPayOtpAPIProtocol {
    let client: HTTPClient
    
    public init(client: HTTPClient = .shared) { self.client = client }
    
    public func requestOtp(_ request: IPayOtpRequest) async throws -> IPayOtpResponse {
        try await client.request(IPayOtpEndpoint.requestOtp(request))
    }
}
