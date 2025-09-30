import Foundation
import Combine     // ← add this

@MainActor
public class OpenSavedTopupViewModel: ObservableObject {
    @Published public var item:  SavedBillItem?
    @Published public var isLoading = false
    @Published public var error: String?
    
    let serviceCode:    String
    let mobileNumber:   String
    let iPayCustomerID: String
    let savedBillID:    String
    
    public init(
        serviceCode: String,
        mobileNumber: String,
        iPayCustomerID: String,
        savedBillID: String
    ) {
        
        self.serviceCode    = serviceCode
        self.mobileNumber   = mobileNumber
        self.iPayCustomerID = iPayCustomerID
        self.savedBillID    = savedBillID
    }
    
    public func load() async {
        isLoading = true
        error     = nil
        defer { isLoading = false }
        
        do {
            let repo = SavedBillRepository()
            let fetched = try await repo.getSavedBill(
                mobileNumber: mobileNumber,
                iPayCustomerID: iPayCustomerID,
                id: savedBillID
            )
            // print("Fetched saved bill: \(fetched)")
            self.item = fetched
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
