import Foundation
import Combine     // ← add this

@MainActor
public class OpenViewVoucherViewModel: ObservableObject {
    @Published public var item:  CheckTransaction?
    @Published public var isLoading = false
    @Published public var error: String?
    
    let serviceCode:    String
    let mobileNumber:   String
    let iPayCustomerID: String
    let billingRef:    String
    
    public init(
        serviceCode: String,
        mobileNumber: String,
        iPayCustomerID: String,
        billingRef: String
    ) {
        
        self.serviceCode    = serviceCode
        self.mobileNumber   = mobileNumber
        self.iPayCustomerID = iPayCustomerID
        self.billingRef    = billingRef
    }
    
    public func load() async {
        isLoading = true
        error     = nil
        defer { isLoading = false }
        
        do {
            let repo = CheckTransactionRepository()
            let fetched = try await repo.checkTransaction(reference: billingRef)
            
//            print("Fetched transaction: \(fetched)")
            
            self.item = fetched.transaction
        } catch let netErr as NetworkError {
            // print("Network error: \(netErr)")
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                error = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                error = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                error = "Bad network configuration"
                
            case .underlying(let err):
                error = err.localizedDescription
            }
        }catch {
            // print("Error: \(error)")
            self.error = error.localizedDescription
        }
    }
}
