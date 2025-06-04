import SwiftUI
import SDWebImageSwiftUI

private class BundleToken {}

public struct OtpView: View {
    @Environment(\.dismiss) private var pop
    @EnvironmentObject private var coord: SDKCoordinator
    
    @StateObject private var vm: OtpViewModel
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var activeIndex: Int? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    // ★ Countdown state
    @State private var remainingSeconds: Int = 0
    private let totalSeconds = 60
    // Timer publisher
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showReceipt = false
    @State private var receiptData: ReceiptData?
    
    public init(
        saveRecharge: String,
        receiverMobileNumber: String,
        countryIso: String,
        countryFlagUrl: URL,
        countryName: String,
        providerCode: String,
        providerLogoUrl: URL,
        providerName: String,
        product: ProductItem,
        mobileNumber: String,
        serviceCode: String,
        iPayCustomerID: String
    ) {
        _vm = StateObject(
            wrappedValue: OtpViewModel(
                saveRecharge: saveRecharge,
                receiverMobileNumber: receiverMobileNumber,
                countryIso: countryIso,
                countryFlagUrl: countryFlagUrl,
                countryName: countryName,
                providerCode: providerCode,
                providerLogoUrl: providerLogoUrl,
                providerName: providerName,
                product: product,
                mobileNumber: mobileNumber,
                serviceCode: serviceCode,
                iPayCustomerID: iPayCustomerID
            )
        )
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer().frame(height: 32)
                
                // Top Bar
                HStack {
                    Image("ic_back", bundle: .module)
                        .onTapGesture { pop() }
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                    
                    Spacer()
                    
                    Image("ic_close", bundle: .module)
                        .onTapGesture { coord.closeSDK() }
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 24)
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 4 of 4")
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
                    
                    Text("Intl Top up")
                        .font(.custom("VodafoneRg-Bold", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text("\(vm.product.sendCurrencyIso) \(vm.product.sendValue)")
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
                    .onTapGesture { isTextFieldFocused = true }
                
                Spacer().frame(height: 32)
                
                // ★ Countdown or Resend OTP
                Group {
                    if remainingSeconds > 0 {
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
                        .indicator(.activity)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }else if vm.showMsgImageType == 2{
                    AnimatedImage(name: "oops.gif", bundle: .mySwiftUIPackage)
                        .indicator(.activity)
                        .resizable()
                        .scaledToFit()
                }
                
                
                Spacer()
            }
            .background(Color.white)
            //            if showReceipt, let data = receiptData {
            //                ReceiptModalView(isPresented: $showReceipt, data: data)
            //            }
        }
        .onAppear {
            Task {
                await vm.requestOtp()
                startTimer()
            }
            isTextFieldFocused = true
        }
        .onChange(of: vm.code) { _, newValue in
            let count = newValue.count
            guard count > 0 else { return }
            
            // mark the last entered digit index
            activeIndex = count - 1
            
            // hide the digit after a short delay, then if 4 digits entered verify
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                activeIndex = nil
                if newValue.count == 4 {
                    Task {
                        //                        print("OTP entered: \(newValue)")
                        await vm.submitOtpAndPoll()
                        //                        receiptData = ReceiptData(
                        //                            amount:       "QR \(vm.product.sendValue)",
                        //                            dateTime: "15 Jul 2024 7:24 AM",
                        //                            type:         "Top up – IMT",
                        //                            number:       vm.receiverMobileNumber,
                        //                            operatorName: vm.providerName,
                        //                            refId:  "121212121212"
                        //                        )
                        //                        withAnimation { showReceipt = true }
                    }
                }
            }
        }
        .onChange(of: vm.completedTransaction?.id) { _, tx in
            guard let tx = vm.completedTransaction else { return }
            receiptData = ReceiptData(
                amount: "\(tx.currency) \(tx.amount)",
                dateTime: tx.dateTime,
                type: "Top up – IMT",
                number: tx.targetIdentifier,
                operatorName: tx.providerName,
                refId: tx.billingRef
            )
            withAnimation { showReceipt = true }
            //            showReceipt = true
        }
        .overlay {
            if showReceipt, let data = receiptData {
                ReceiptModalView(
                    isPresented: $showReceipt,
                    data:        data
                )
            }
        }
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
    private var otpBoxes: some View {
        ZStack {
            // Hidden TextField to capture input
            TextField("", text: $vm.code)
                .focused($isTextFieldFocused)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onChange(of: vm.code) { _, v in
                    // cap at 4
                    vm.code = String(v.prefix(4))
                }
                .foregroundColor(.clear)
                .accentColor(.clear)
                .frame(width: 0, height: 0) // Hide from layout
            
            // The visible 4 boxes
            HStack(spacing: 24) {
                ForEach(0..<4) { idx in
                    ZStack {
                        // Background & border
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color("keyBs_bg_gray_1", bundle: .module), lineWidth: 1)
                            .background(
                                (idx < vm.code.count)
                                ? Color.white     // filled or active
                                : Color("keyBs_bg_gray_5", bundle: .module)  // unfilled
                            )
                            .cornerRadius(5)
                            .frame(width: 46, height: 46)
                        
                        // Content
                        if idx < vm.code.count {
                            if activeIndex == idx {
                                // ACTIVE: show the digit
                                Text(String(Array(vm.code)[idx]))
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
                // focus the hidden text field
                isTextFieldFocused = true
            }
        }
        .frame(height: 46)
    }
}

#Preview {
    OtpView(
        saveRecharge: "1",
        receiverMobileNumber: "45456456",
        countryIso: "AE",
        countryFlagUrl: URL(string: "http://keybs.ai/fg/ae.svg")!,
        countryName: "United Arab Emirates",
        providerCode: "E6AE",
        providerLogoUrl: URL(string: "https://imagerepo.ding.com/logo/DU/AE.png")!,
        providerName: "DU UAE",
        product: ProductItem(
            skuCode: "E6AEAE12938",
            providerCode: "E6AE",
            countryIso: "AE",
            displayText: "AED 20.00",
            sendValue: "28",
            sendCurrencyIso: "QR"
        ),
        mobileNumber: "88776630",
        serviceCode: "INT_TOP_UP",
        iPayCustomerID: "13"
    )
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(
            saveRecharge: "1",
            receiverMobileNumber: "45456456",
            countryIso: "AE",
            countryFlagUrl: URL(string: "http://keybs.ai/fg/ae.svg")!,
            countryName: "United Arab Emirates",
            providerCode: "E6AE",
            providerLogoUrl: URL(string: "https://imagerepo.ding.com/logo/DU/AE.png")!,
            providerName: "DU UAE",
            product: ProductItem(
                skuCode: "E6AEAE12938",
                providerCode: "E6AE",
                countryIso: "AE",
                displayText: "AED 20.00",
                sendValue: "28",
                sendCurrencyIso: "QR"
            ),
            mobileNumber: "88776630",
            serviceCode: "INT_TOP_UP",
            iPayCustomerID: "13"
        )
        .previewLayout(.sizeThatFits)
    }
}
