import Foundation

public class IPayOtpRepository {
    let api: IPayOtpAPIProtocol
    public init(api: IPayOtpAPIProtocol = IPayOtpAPI()) { self.api = api }
    
    public func sendOtp(
        mobileNumber:   String,
        iPayCustomerID: String,
        targetNumber:   String,
        serviceCode:    String,
        productSku:     String,
        saveRecharge:   String,
        billAmount: String,
        settingsData: String
    ) async throws -> IPayOtpResponse {
        // print("IPayOtpRepository sendOtp")
        let req = IPayOtpRequest(
            mobileNumber:   mobileNumber,
            iPayCustomerID: iPayCustomerID,
            targetNumber:   targetNumber,
            serviceCode:    serviceCode,
            productSku:     productSku,
            saveRecharge:   saveRecharge,
            billAmount:     billAmount,
            settingsData:   settingsData
        )
        let resp = try await api.requestOtp(req)
        // print("IPayOtp: \(resp)")
        return resp
    }
}
