import Foundation
import Combine     // ← add this

@MainActor
public class EnterAmountViewModel: ObservableObject {
    
    // ── Products ────────────────────────────────────────────────
    @Published public var products: [ProductItem] = []
    @Published public var isLoadingProducts = false
    @Published public var productsError: String? = nil
    @Published public var selectedProduct: ProductItem?

    // ── Input state (injection) ─────────────────────────────────
    @Published public var saveRecharge: String
    
    @Published public var countryIso: String
    @Published public var countryFlagUrl: URL
    @Published public var countryName: String
    @Published public var countryPrefix: String
    @Published public var countryMinimumLength: String
    @Published public var countryMaximumLength: String
    
    @Published public var providerCode: String
    @Published public var providerLogoUrl: URL
    @Published public var providerName: String
    @Published public var providerValidationRegex: String
    
    @Published public var productSku: String
    @Published public var receiverMobileNumber: String
    @Published public var settingsData: String
    
    @Published public var mobileNumber: String
    @Published public var serviceCode: String
    @Published public var iPayCustomerID: String

    @Published public var dismissMode: String
    
    public init(
        saveRecharge: String,
        
        countryIso: String,
        countryFlagUrl: URL,
        countryName: String,
        countryPrefix: String,
        countryMinimumLength: String,
        countryMaximumLength: String,
        
        providerCode: String,
        providerLogoUrl: URL,
        providerName: String,
        providerValidationRegex: String,
        
        productSku: String,
        receiverMobileNumber: String,
        settingsData: String,
        
        mobileNumber: String,
        serviceCode: String,
        iPayCustomerID: String,
        
        dismissMode: String
    ) {
        self.saveRecharge = saveRecharge
        
        self.countryIso = countryIso
        self.countryFlagUrl = countryFlagUrl
        self.countryName = countryName
        self.countryPrefix = countryPrefix
        self.countryMinimumLength = countryMinimumLength
        self.countryMaximumLength = countryMaximumLength
        
        self.providerCode = providerCode
        self.providerLogoUrl = providerLogoUrl
        self.providerName = providerName
        self.providerValidationRegex = providerValidationRegex
        
        self.productSku = productSku
        self.receiverMobileNumber = receiverMobileNumber
        self.settingsData = settingsData
        
        self.mobileNumber = mobileNumber
        self.serviceCode = serviceCode
        self.iPayCustomerID = iPayCustomerID
        
        self.dismissMode = dismissMode
    }
    
    // MARK: – Products
    public func loadProducts() async {
        isLoadingProducts = true
        productsError     = nil
        defer { isLoadingProducts = false }
        
        do {
            let repo = ProductsRepository()
            products = try await repo.getProducts(
                mobileNumber: mobileNumber,
                serviceCode:  serviceCode,
                countryCode:  countryIso,
                providerCode: providerCode
            )
            
            if products.count == 1 {
                selectedProduct = products.first
            }else{
                if !productSku.isEmpty {
                    selectedProduct = products.first(where: { $0.skuCode == productSku })
                }
            }
        } catch let netErr as NetworkError {
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                productsError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                productsError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                productsError = "Bad network configuration"
                
            case .underlying(let err):
                productsError = err.localizedDescription
            }
        } catch {
            productsError = error.localizedDescription
        }
    }
}
