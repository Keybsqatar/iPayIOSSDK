import SwiftUI
import SDWebImageSwiftUI

private class BundleToken {}

public struct OtpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: OtpViewModel
    // @ObservedObject var vm: OtpViewModel
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var otbCode = ""
    
    @State private var activeIndex: Int? = nil
    // @FocusState private var isTextFieldFocused: Bool
    @State private var isTextFieldFocused: Bool = false
    
    // ★ Countdown state
    @State private var remainingSeconds: Int = 0
    private let totalSeconds = 60
    // Timer publisher
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showReceipt = false
    @State private var receiptData: ReceiptData?
    
    // public init(
    //     saveRecharge: String,
    //     receiverMobileNumber: String,
    //     countryIso: String,
    //     countryFlagUrl: URL,
    //     countryName: String,
    //     providerCode: String,
    //     providerLogoUrl: URL,
    //     providerName: String,
    //     product: ProductItem,
    //     mobileNumber: String,
    //     serviceCode: String,
    //     iPayCustomerID: String
    // ) {
    //     self.vm = OtpViewModel(
    //         saveRecharge: saveRecharge,
    //         receiverMobileNumber: receiverMobileNumber,
    //         countryIso: countryIso,
    //         countryFlagUrl: countryFlagUrl,
    //         countryName: countryName,
    //         providerCode: providerCode,
    //         providerLogoUrl: providerLogoUrl,
    //         providerName: providerName,
    //         product: product,
    //         mobileNumber: mobileNumber,
    //         serviceCode: serviceCode,
    //         iPayCustomerID: iPayCustomerID
    //     )
    // }
    
    // Existing initializer (with all parameters)
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
        self.vm = OtpViewModel(
            saveRecharge: saveRecharge,
            
            countryIso: countryIso,
            countryFlagUrl: countryFlagUrl,
            countryName: countryName,
            
            providerCode: providerCode,
            providerLogoUrl: providerLogoUrl,
            providerName: providerName,
            
            product: product,
            billAmount: billAmount,
            
            receiverMobileNumber: receiverMobileNumber,
            settingsData: settingsData,
            
            mobileNumber: mobileNumber,
            serviceCode: serviceCode,
            iPayCustomerID: iPayCustomerID
        )
    }
    
    // ADD THIS CONVENIENCE INITIALIZER:
    public init(vm: OtpViewModel) {
        self.vm = vm
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer().frame(height: 32)
                
                // Top Bar
                HStack {
                    Image("ic_back", bundle: .module)
                        .onTapGesture { presentationMode.wrappedValue.dismiss() }
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                    
                    Spacer()
                    
                    Image("ic_close", bundle: .module)
                        .onTapGesture { coord.dismissSDK() }
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 24)
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text(vm.serviceCode == "INT_UTIL_PAYMENT" ? "Step 5 of 5" : "Step 4 of 4")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Text("Enter OTP")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                // Transaction type card (you can parameterize this)
                HStack(spacing: 4) {
                    Image("ic_transaction_type", bundle: .module)
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                    
                    Text(
                        vm.serviceCode == "INT_TOP_UP" ? "Intl Top up" :
                            vm.serviceCode == "INT_VOUCHER" ? "Voucher" :
                            vm.serviceCode == "INT_UTIL_PAYMENT" ? "Intl Utility" : ""
                    )
                    .font(.custom("VodafoneRg-Bold", size: 16))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(
                        (vm.billAmount.isEmpty || vm.billAmount == "0")
                        ? "\(vm.product.sendCurrencyIso) \(vm.product.sendValue)"
                        : "\(vm.product.sendCurrencyIso) \(vm.billAmount)"
                    )
                    .font(.custom("VodafoneRg-Bold", size: 24))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
                }
                .padding(.all, 16)
                .background(Color("keyBs_bg_pink_1", bundle: .module))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                // OTP boxes
                otpBoxes
                    .padding(.horizontal, 40)
                //                    .onTapGesture {
                //                        print("Tapped OTP boxes")
                //                        isTextFieldFocused = true
                //                    }
                
                Spacer().frame(height: 32)
                
                // ★ Countdown or Resend OTP
                Group {
                    if(vm.showMsgImageType == 3) {
                        Button("Invalid OTP") {
                            Task {
                                await vm.requestOtp()
                                startTimer()
                            }
                        }
                        .font(.custom("VodafoneRg-Bold", size: 16))
                        .foregroundColor(Color("keyBs_bg_red_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    } else if remainingSeconds > 0 {
                        Text("\(formatTime(remainingSeconds))")
                            .font(.custom("VodafoneRg-Bold", size: 16))
                            .foregroundColor(Color("keyBs_bg_red_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                    } else {
                        Button("Resend OTP") {
                            Task {
                                await vm.requestOtp()
                                startTimer()
                            }
                        }
                        .font(.custom("VodafoneRg-Bold", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_4", bundle: .module))
                        .multilineTextAlignment(.leading)
                    }
                }
                .onReceive(timer) { _ in
                    guard remainingSeconds > 0 else { return }
                    remainingSeconds -= 1
                }
                
                Spacer().frame(height: 32)
                
                if vm.showMsgImageType == 1{
                    AnimatedImage(name: "spinner.gif", bundle: .mySwiftUIPackage)
                    //                        .indicator(.activity)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
//                        .frame(height: 20)
                }
                //                else if vm.showMsgImageType == 2{
                //                    AnimatedImage(name: "oops.gif", bundle: .mySwiftUIPackage)
                //                    //                        .indicator(.activity)
                //                        .resizable()
                //                        .scaledToFit()
                //                        .frame(height: 56)
                //                }
                
                Spacer()
            }
            .background(Color.white)
        }
        .onAppear {
            Task {
                await vm.requestOtp()
                startTimer()
            }
            //            print("OTP View appeared, requesting OTP")
            isTextFieldFocused = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: Notification.Name("OtpCodeChanged"))
        ) { _ in
            let newValue = otbCode
            //            print("OTP code changed: \(newValue)")
            
            if(vm.showMsgImageType == 3) {
                vm.showMsgImageType = 0
                remainingSeconds = 0
            }
            
            let count = newValue.count
            guard count > 0 else { return }
            activeIndex = count - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                activeIndex = nil
                if newValue.count == 4 {
                    Task {
                        await vm.submitOtpAndPoll(for: newValue)
                    }
                }
            }
        }
        .onReceive(vm.$showReceiptModal) { shouldShow in
            if shouldShow {
                guard let tx = vm.completedTransaction else { return }
                // print("OptView shouldShow Completed transaction status: \(tx.status)")
                
                receiptData = ReceiptData(
                    status: tx.status, // ✅ Show PENDING when processing
                    amount: "\(tx.currency) \(tx.amount)",
                    dateTime: tx.dateTime,
                    type: vm.serviceCode == "INT_TOP_UP" ? "Top up – IMT" :
                        vm.serviceCode == "INT_VOUCHER" ? "Voucher" :
                        vm.serviceCode == "INT_UTIL_PAYMENT" ? "Top up - Utility" : "",
                    number: tx.targetIdentifier,
                    operatorName: tx.providerName,
                    refId: tx.billingRef,
                    
                    countryName: vm.countryName,
                    countryFlagUrl: vm.countryFlagUrl,
                    providerName: vm.providerName,
                    providerLogoUrl: vm.providerLogoUrl,
                    product: vm.product,
                    
                    readMoreMarkdown: tx.readMoreMarkdown,
                    descriptionMarkdown: tx.descriptionMarkdown,
                    
                    textPin: vm.textPin,
                    valuePin: vm.valuePin,
                    
                    isPending: vm.isTransactionPending
                )
                withAnimation { showReceipt = true }
            }
        }
        .onReceive(vm.$completedTransaction) { tx in
            guard let tx = tx, showReceipt else { return } // ✅ Only update if receipt is already showing
            // print("OptView Completed transaction status: \(tx.status)")
            
            receiptData = ReceiptData(
                status: tx.status, // ✅ Update status based on pending state
                amount: "\(tx.currency) \(tx.amount)",
                dateTime: tx.dateTime,
                type: vm.serviceCode == "INT_TOP_UP" ? "Top up – IMT" :
                    vm.serviceCode == "INT_VOUCHER" ? "Voucher" :
                    vm.serviceCode == "INT_UTIL_PAYMENT" ? "Top up - Utility" : "",
                number: tx.targetIdentifier,
                operatorName: tx.providerName,
                refId: tx.billingRef,
                
                countryName: vm.countryName,
                countryFlagUrl: vm.countryFlagUrl,
                providerName: vm.providerName,
                providerLogoUrl: vm.providerLogoUrl,
                product: vm.product,
                
                readMoreMarkdown: tx.readMoreMarkdown,
                descriptionMarkdown: tx.descriptionMarkdown,
                
                textPin: vm.textPin,
                valuePin: vm.valuePin,
                
                isPending: vm.isTransactionPending
            )
        }
//        .onReceive(vm.$showReceiptModal) { shouldShow in
//            if shouldShow {
//                // Create receipt data immediately
//                guard let tx = vm.completedTransaction else { return }
//                print("OptView shouldShow Completed transaction status: \(tx.status)")
//                
////                let textPin = ""
////                let valuePin = ""
//                
////                let receiptParamsString = tx.reciptParams
////                if let data = receiptParamsString.data(using: .utf8),
////                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
////                   let (key, value) = json.first {
////                     
////                    vm.textPin = key
////                    vm.valuePin = "\(value)"
////                     
////                }
//                
//                receiptData = ReceiptData(
//                    status: tx.status,
//                    
//                    amount: "\(tx.currency) \(tx.amount)",
//                    dateTime: tx.dateTime,
//                    type: vm.serviceCode == "INT_TOP_UP" ? "Top up – IMT" :
//                        vm.serviceCode == "INT_VOUCHER" ? "Voucher" :
//                        vm.serviceCode == "INT_UTIL_PAYMENT" ? "Top up - Utility" : "",
//                    number: tx.targetIdentifier,
//                    operatorName: tx.providerName,
//                    refId: tx.billingRef,
//                    
//                    countryName: vm.countryName,
//                    countryFlagUrl: vm.countryFlagUrl,
//                    providerName: vm.providerName,
//                    providerLogoUrl: vm.providerLogoUrl,
//                    product: vm.product,
//                    
//                    readMoreMarkdown: tx.readMoreMarkdown,
//                    descriptionMarkdown: tx.descriptionMarkdown,
//                    
//                    textPin: vm.textPin,
//                    valuePin: vm.valuePin,
//                    
//                    isPending: vm.isTransactionPending
//                )
//                withAnimation { showReceipt = true }
//            }
//        }
//        .onReceive(vm.$completedTransaction) { tx in
//            guard let tx = tx else { return }
//            print("OptView Completed transaction status: \(tx.status)")
//            receiptData = ReceiptData(
//                // status: tx.status,
//                status: tx.status,
//                
//                amount: "\(tx.currency) \(tx.amount)",
//                dateTime: tx.dateTime,
//                //                type: vm.serviceCode != "INT_VOUCHER" ? "Top up – IMT" : "Voucher",
//                type: vm.serviceCode == "INT_TOP_UP" ? "Top up – IMT" :
//                    vm.serviceCode == "INT_VOUCHER" ? "Voucher" :
//                    vm.serviceCode == "INT_UTIL_PAYMENT" ? "Top up - Utility" : "",
//                number: tx.targetIdentifier,
//                operatorName: tx.providerName,
//                refId: tx.billingRef,
//                
//                countryName: vm.countryName,
//                countryFlagUrl: vm.countryFlagUrl,
//                providerName: vm.providerName,
//                providerLogoUrl: vm.providerLogoUrl,
//                product: vm.product,
//                
//                readMoreMarkdown: tx.readMoreMarkdown,
//                descriptionMarkdown: tx.descriptionMarkdown,
//                
//                textPin: vm.textPin,
//                valuePin: vm.valuePin,
//                
//                isPending: vm.isTransactionPending
//            )
//            withAnimation { showReceipt = true }
//        }
        .overlay(receiptOverlay)
        .onReceive(vm.$iPayOtpError) { msg in
            if let m = msg {
                toastMessage = m
                showToast    = true
            }
        }
        .toast(isShowing: $showToast, message: toastMessage)
        .toast(isShowing: Binding(
            get: { vm.otpError != nil },
            set: { if !$0 { vm.otpError = nil } }
        ), message: vm.otpError ?? "")
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    private func startTimer() {
        remainingSeconds = totalSeconds
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    @ViewBuilder
    private var receiptOverlay: some View {
        if showReceipt, let data = receiptData {
            if(vm.serviceCode == "INT_TOP_UP"){
                ReceiptModalView(isPresented: $showReceipt, data: data)
            }else if(vm.serviceCode == "INT_VOUCHER"){
                VoucherReceiptModalView(isPresented: $showReceipt, data: data)
            }else if(vm.serviceCode == "INT_UTIL_PAYMENT"){
                UtilityReceiptModalView(isPresented: $showReceipt, data: data)
            }
        }
    }
    
    @ViewBuilder
    private var otpBoxes: some View {
        ZStack {
            // Hidden TextField to capture input
            
            FocusableTextField(text: $otbCode, isFirstResponder: $isTextFieldFocused, isDisabled: vm.otpDisabled)
                .frame(width: 0, height: 0)
            
            // The visible 4 boxes
            HStack(spacing: 24) {
                ForEach(0..<4) { idx in
                    ZStack {
                        // Background & border
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(vm.showMsgImageType != 3 ? "keyBs_bg_gray_1" : "keyBs_bg_red_1", bundle: .module), lineWidth: 1)
                            .background(
                                (idx < otbCode.count)
                                ? Color.white     // filled or active
                                : Color("keyBs_bg_gray_5", bundle: .module)  // unfilled
                            )
                            .cornerRadius(5)
                            .frame(width: 46, height: 46)
                        
                        // Content
                        if idx < otbCode.count {
                            if activeIndex == idx {
                                // ACTIVE: show the digit
                                Text(String(Array(otbCode)[idx]))
                                    .font(.custom("VodafoneRg-Bold", size: 20))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            } else {
                                // FILLED: show a red dot
                                Circle()
                                    .fill(Color("keyBs_font_red_1", bundle: .module))
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = false // Dismiss any current focus
                // focus the hidden text field
                //                print("Tapped OTP boxes, focusing text field")
                isTextFieldFocused = true
            }
        }
        .frame(height: 46)
    }
}

// Add this helper at the bottom of your file
struct FocusableTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var isDisabled: Bool = false
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.delegate = context.coordinator
        textField.isHidden = true // Hide from UI
        textField.isUserInteractionEnabled = !isDisabled // <-- Set disabled state
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        // uiView.text = text
        uiView.text = String(text.prefix(4))
        uiView.isUserInteractionEnabled = !isDisabled // <-- Update disabled state
        
        //        print("Updating UITextField with text: \(uiView.text ?? "")")
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
        
        init(_ parent: FocusableTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            // parent.text = textField.text ?? ""
            parent.text = String(textField.text!.prefix(4)) ?? ""
            NotificationCenter.default.post(name: Notification.Name("OtpCodeChanged"), object: nil)
            //            print("TextField changed: \(parent.text)")
        }
    }
}
