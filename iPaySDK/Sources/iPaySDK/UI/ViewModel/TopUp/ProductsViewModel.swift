import Foundation
import Combine     // ← add this

@MainActor
public class ProductsViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var selectedClass: String = "1"
    private var cancellables = Set<AnyCancellable>()

    // ── Products ────────────────────────────────────────────────
    @Published public var products: [ProductItem] = []
    @Published public var filteredProducts: [ProductItem] = []
    
    @Published public var isLoadingProducts = false
    @Published public var productsLoaded = false
    @Published public var productsError: String? = nil
    @Published public var selectedProduct: ProductItem?

    // ── Input state (injection) ─────────────────────────────────
    @Published public var saveRecharge: String
    @Published public var receiverMobileNumber: String
    @Published public var countryIso: String
    @Published public var countryFlagUrl: URL
    @Published public var countryName: String
    @Published public var providerCode: String
    @Published public var providerLogoUrl: URL
    @Published public var providerName: String
    @Published public var productSku: String
    
    @Published public var mobileNumber: String
    @Published public var serviceCode: String
    @Published public var iPayCustomerID: String

    @Published public var dismissMode: String
    
    public init(
        saveRecharge: String,
        receiverMobileNumber: String,
        countryIso: String,
        countryFlagUrl: URL,
        countryName: String,
        providerCode: String,
        providerLogoUrl: URL,
        providerName: String,
        productSku: String,
        
        mobileNumber: String,
        serviceCode: String,
        iPayCustomerID: String,
        
        dismissMode: String
    ) {
        self.saveRecharge = saveRecharge
        self.receiverMobileNumber = receiverMobileNumber
        self.countryIso = countryIso
        self.countryFlagUrl = countryFlagUrl
        self.countryName = countryName
        self.providerCode = providerCode
        self.providerLogoUrl = providerLogoUrl
        self.providerName = providerName
        self.productSku = productSku
        
        self.mobileNumber = mobileNumber
        self.serviceCode = serviceCode
        self.iPayCustomerID = iPayCustomerID
        
        self.dismissMode = dismissMode
        
        $searchText
                 .removeDuplicates()
                 .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                 .sink { [weak self] value in
                     self?.filterProducts(by: value)
                 }
                 .store(in: &cancellables)
    }
    
    func filterProducts(by query: String) {
        if query.isEmpty {
            filteredProducts = products.filter { $0.classification == selectedClass }
        } else {
            filteredProducts = products.filter {
                $0.classification == "2" && (
                    $0.displayText.localizedCaseInsensitiveContains(query) ||
                    $0.descriptionMarkdown?.localizedCaseInsensitiveContains(query) == true
                )
            }
        }
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
            productsLoaded = true;
            if !productSku.isEmpty {
                selectedProduct = products.first(where: { $0.skuCode == productSku })
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
