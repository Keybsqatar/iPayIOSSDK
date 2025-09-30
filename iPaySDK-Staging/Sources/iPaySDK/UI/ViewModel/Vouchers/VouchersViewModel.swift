import Foundation
import Combine     // ← add this


@MainActor
public class VouchersViewModel: ObservableObject {
    
    // ── Countries ────────────────────────────────────────────────
    @Published public var countries: [CountryItem]   = []
    @Published public var filteredCountries: [CountryItem] = []
    @Published public var isLoadingCountries: Bool  = false
    @Published public var countriesError: String?    = nil
    @Published public var mobileMaxLength: Int = 0
    @Published public var mobileMinLength: Int = 0
    @Published public var countrySearch: String = ""
    private var cancellables = Set<AnyCancellable>()


    // ── Providers ───────────────────────────────────────────────
    @Published public var providers: [ProviderItem] = []
    @Published public var isLoadingProviders: Bool  = false
    @Published public var providersError: String?   = nil
    
    // ── Saved Bills ──────────────────────────────────────────
    @Published public var savedBills:          [SavedBillsItem] = []
    @Published public var isLoadingSavedBills: Bool = false
    @Published public var savedBillsError:     String?
    
    // ── Delete Bill ──────────────────────────────────────────
    @Published public var isDeletingBill: Bool = false
    @Published public var deleteBillError: String?
    private let deleteRepo = DeleteBillRepository()
    @Published public var deleteSuccessMessage: String? = nil
    
    
    // ── Input state (injection) ─────────────────────────────────
    @Published public var serviceCode:  String
    @Published public var mobileNumber: String
    @Published public var iPayCustomerID: String
    
    public init(serviceCode: String, mobileNumber: String, iPayCustomerID: String) {
        self.serviceCode  = serviceCode
        self.mobileNumber = mobileNumber
        self.iPayCustomerID = iPayCustomerID
        $countrySearch
                .removeDuplicates()
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .sink { [weak self] value in
                    self?.filterCountries(by: value)
                }
                .store(in: &cancellables)
    }
    
    // MARK: – Countries
    public func loadCountries() async {
        isLoadingCountries = true
        countriesError     = nil
        defer { isLoadingCountries = false }
        
        do {
            let repo  = CountriesRepository()
            let items = try await repo.getCountries(
                mobileNumber: mobileNumber,
                serviceCode:  serviceCode
            )
            countries          = items
            filteredCountries  = items

        } catch let netErr as NetworkError {
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                countriesError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                countriesError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                countriesError = "Bad network configuration"
                
            case .underlying(let err):
                countriesError = err.localizedDescription
            }
        } catch {
            countriesError = error.localizedDescription
        }
    }
    public func filterCountries(by text: String) {
        guard !text.isEmpty else {
            filteredCountries = countries
            return
        }
        filteredCountries = countries.filter {
            $0.name.localizedCaseInsensitiveContains(text)
        }
    }
    
    // MARK: – Providers
    public func loadProviders(for countryIso: String) async {
        isLoadingProviders = true
        providersError     = nil
        defer { isLoadingProviders = false }
        
        do {
            let repo  = ProvidersRepository()
            let items = try await repo.getProviders(
                mobileNumber:  mobileNumber,
                serviceCode:   serviceCode,
                countryCode:   countryIso,
                targetNumber: ""
            )
//            print("successfully fetched providers: \(items)")
            providers = items
        } catch let netErr as NetworkError {
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                providersError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                providersError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                providersError = "Bad network configuration"
                
            case .underlying(let err):
                providersError = err.localizedDescription
            }
        } catch {
            providersError = error.localizedDescription
        }
    }
    
    // MARK: – Saved Bills
    public func loadSavedBills() async {
        isLoadingSavedBills = true
        savedBillsError     = nil
        defer { isLoadingSavedBills = false }
        
        do {
            let items = try await SavedBillsRepository()
                .getSavedBills(
                    mobileNumber: mobileNumber,
                    iPayCustomerID: iPayCustomerID,
                    serviceCode: serviceCode
                )
            
//            print("Fetched saved bills: \(items)")
            
            self.savedBills = items
            
        } catch let netErr as NetworkError {
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                savedBillsError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                savedBillsError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                savedBillsError = "Bad network configuration"
                
            case .underlying(let err):
                savedBillsError = err.localizedDescription
            }
        } catch {
            savedBillsError = error.localizedDescription
        }
    }
    
    // MARK: – Delete Bill
    public func deleteSavedBill(_ bill: SavedBillsItem) async {
        isDeletingBill   = true
        deleteBillError  = nil
        deleteSuccessMessage = nil
        defer { isDeletingBill = false }
        
        do {
            let resp = try await DeleteBillRepository()
                .deleteBill(id: bill.id)
            
            
            if resp.status == "SUCCESS" {
                // remove locally
                savedBills.removeAll { $0.id == bill.id }
                
                deleteSuccessMessage = resp.message
            }else {
                deleteBillError = resp.message
            }
        } catch let netErr as NetworkError {
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                deleteBillError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                deleteBillError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                deleteBillError = "Bad network configuration"
                
            case .underlying(let err):
                deleteBillError = err.localizedDescription
            }
        }catch {
            deleteBillError = error.localizedDescription
        }
    }
}
