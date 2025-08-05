import Foundation
import Combine     // ← add this

@MainActor
public class OtpViewModel: ObservableObject {
    
    // ── iPayOtp ────────────────────────────────────────────────
    @Published public var transactionId:   Int?
    @Published public var isLoadingIPayOtp:    Bool   = false
    @Published public var iPayOtpError:    String?
    
    @Published public var code:            String = ""
    @Published public var showMsgImageType: Int = 0
    // @Published public var isVerifyingOtp:  Bool   = false
    
    
    @Published public var completedTransaction: CheckTransaction?
    @Published public var textPin: String = ""
    @Published public var valuePin: String = ""
    
    @Published public var otpError: String?
    @Published public var isSubmitting: Bool = false
    
    @Published public var otpDisabled: Bool = true
    
    // ── Input state (injection) ─────────────────────────────────
    public let saveRecharge: String
    
    public let countryIso: String
    public let countryFlagUrl: URL
    public let countryName: String
    
    public let providerCode: String
    public let providerLogoUrl: URL
    public let providerName: String
    
    public let product: ProductItem
    public let billAmount: String
    
    public let receiverMobileNumber: String
    public let settingsData: String
    
    public let mobileNumber: String
    public let serviceCode: String
    public let iPayCustomerID: String
    
    public init(
        saveRecharge: String,
        
        countryIso: String,
        countryFlagUrl: URL,
        countryName: String,
        
        providerCode: String,
        providerLogoUrl: URL,
        providerName: String,
        
        product: ProductItem,
        billAmount: String,
        
        receiverMobileNumber: String,
        settingsData: String,
        
        mobileNumber: String,
        serviceCode: String,
        iPayCustomerID: String
    ) {
        self.saveRecharge = saveRecharge
        
        self.countryIso = countryIso
        self.countryFlagUrl = countryFlagUrl
        self.countryName = countryName
        
        self.providerCode = providerCode
        self.providerLogoUrl = providerLogoUrl
        self.providerName = providerName
        
        self.product = product
        self.billAmount = billAmount
        
        self.receiverMobileNumber = receiverMobileNumber
        self.settingsData = settingsData
        
        self.mobileNumber = mobileNumber
        self.serviceCode = serviceCode
        self.iPayCustomerID = iPayCustomerID
    }
    
    // MARK: – iPayOtp
    public func requestOtp() async {
        // For debugging purposes, you can uncomment the following lines to simulate a successful OTP request without making an actual network call.
//         otpDisabled = false
//         return
//        
        isLoadingIPayOtp  = true
        iPayOtpError  = nil
        defer { isLoadingIPayOtp = false }
        
        otpDisabled = true
        
        do {
            let resp = try await IPayOtpRepository()
                .sendOtp(
                    mobileNumber:   mobileNumber,
                    iPayCustomerID: iPayCustomerID,
                    targetNumber:   receiverMobileNumber,
                    serviceCode:    serviceCode,
                    productSku:     product.skuCode,
                    saveRecharge:   saveRecharge,
                    billAmount: billAmount,
                    settingsData:   settingsData
                )
            
            if(resp.status == "SUCCESS") {
                transactionId = resp.transactionId
                showMsgImageType = 0
                iPayOtpError = "OTP sent"
                
                otpDisabled = false
            }else{
                showMsgImageType = 2
                iPayOtpError = resp.message ?? "Unknown error occurred"
            }
        } catch let netErr as NetworkError {
            otpDisabled = false
            showMsgImageType = 2
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                
                iPayOtpError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                
                iPayOtpError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                
                iPayOtpError = "Bad network configuration"
                
            case .underlying(let err):
                
                iPayOtpError = err.localizedDescription
            }
        } catch {
            otpDisabled = false
            showMsgImageType = 2
            iPayOtpError = error.localizedDescription
        }
    }
    
    public func submitOtpAndPoll(for otbCode: String) async {
        // For debugging purposes, you can uncomment the following lines to simulate a successful transaction without making an actual network call.
//         textPin = "pin"
//         valuePin = "001234567890"
//         completedTransaction = CheckTransaction(
//                 id: "123456",
//                 mobileNumber: mobileNumber,
//                 iPayCustomerID: iPayCustomerID,
//                 targetIdentifier: receiverMobileNumber,
//                 countryIso2: countryIso,
//                 countryIso3: countryIso,
//                 countryName: countryName,
//                 countryFlagUrl: countryFlagUrl,
//                 providerCode: providerCode,
//                 providerName: providerName,
//                 providerImgUrl: providerLogoUrl,
//                 productSku: product.skuCode,
//                 productDisplayText: product.displayText,
//                 serviceCode: serviceCode,
//                 amount: billAmount,
//                 currency: product.sendCurrencyIso,
//                 billingRef: "FAKEBILLREF123",
//                 status: "SUCCESS",
//                 statusMessage: "Transaction completed successfully",
//                 reciptParams: "{\"pin\":\"001234567890\"}",
//                 descriptionMarkdown: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
//                 readMoreMarkdown: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
//                 dateTime: "29 Jul 2025, 14:30"
//         )
//         showMsgImageType = 0
//         return
        
        guard otbCode.count == 4,
              let txId = transactionId  // from your earlier iPayOtp call
        else { return }
        
        isSubmitting = true
        otpError     = nil
        defer { isSubmitting = false }
        
        otpDisabled = true
        
        do {
            showMsgImageType = 1
            
            let orderRepo = IPayOrderRepository()
            
            let orderResp = try await orderRepo.placeOrder(
                otp: otbCode,
                transactionId: String(txId)
            )
            
            //            print("orderResp: \(orderResp)")
            
            if orderResp.status != "SUCCESS" {
                if let message = orderResp.message, message.contains("4023") {
                    otpError = orderResp.message
                    showMsgImageType = 3
                    otpDisabled = false
                }else{
                    otpError = orderResp.message ?? "Unknown error occurred"
                    showMsgImageType = 2
                    otpDisabled = false
                }
                return
            }
            
            let reference = orderResp.transactionReference!
            
            let checkRepo = CheckTransactionRepository()
            var checkResp: CheckTransactionResponse? = nil
            
            for _ in 1...13 { // Poll up CheckTransaction to 13 times, with a delay of 5 seconds each
                //                print("Polling at: \(Date())")
                // try await Task.sleep(for: .seconds(5))
                try await Task.sleep(nanoseconds: 5_000_000_000)
                
                // let checkRepo = CheckTransactionRepository()
                // let checkResp = try await checkRepo.checkTransaction(reference: reference)
                
                checkResp = try await checkRepo.checkTransaction(reference: reference)
                
                //                 print("checkResp: \(checkResp)")
                if let checkResp = checkResp, checkResp.status == "SUCCESS" {
                    if checkResp.transaction.status == "SUCCESS" {
//                        print("SUCCESS")
                        let receiptParamsString = checkResp.transaction.reciptParams
                        if let data = receiptParamsString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let (key, value) = json.first {
                            textPin = key
                            valuePin = "\(value)"
                        }
//                        else{
//                            textPin = "pin"
//                            valuePin = "001912349671"
//                        }
                        
                        completedTransaction = checkResp.transaction
                        
                        showMsgImageType = 0
                        return
                    } else if checkResp.transaction.status == "FAILED" {
//                        print("FAILED")

                        completedTransaction = checkResp.transaction
                        
                        showMsgImageType = 2
                        otpError = checkResp.transaction.statusMessage
                        otpDisabled = false
                        return
                    }
                }
            }
            
//            print("Transaction failed")
            // 3) if we get here, no SUCCESS after 3 tries
            if let checkResp = checkResp, checkResp.status == "SUCCESS" {
                completedTransaction = checkResp.transaction
            }

            showMsgImageType = 2
            otpError = "Transaction failed"
            otpDisabled = false
            
        } catch let netErr as NetworkError {
            
            showMsgImageType = 2
            otpDisabled = false
            // unwrap your NetworkError enum
            switch netErr {
            case .apiError(_, let apiErr):
                // server-side error → show its human message
                otpError = apiErr.userMessage()
                
            case .decodingError(let decodeErr):
                otpError = "Decoding error: \(decodeErr.localizedDescription)"
                
            case .invalidURL, .invalidResponse:
                otpError = "Bad network configuration"
                
            case .underlying(let err):
                otpError = err.localizedDescription
            }
        } catch {
            otpDisabled = false
            showMsgImageType = 2
            otpError = error.localizedDescription
        }
    }
}
