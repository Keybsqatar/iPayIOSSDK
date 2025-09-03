import SwiftUI
import Combine

public struct EnterAmountView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: EnterAmountViewModel
    
    @State private var amount: String = ""
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var disabledProceed = true
    @State private var showEnterUtility = false
    
    @State private var productsCount: Int = 0
    
    public init(
        saveRecharge: String,
        
        countryIso: String,
        countryFlagUrl: URL,
        countryName: String,
        countryPrefix: String,
        // countryMinimumLength: String,
        // countryMaximumLength: String,
        
        providerCode: String,
        providerLogoUrl: URL,
        providerName: String,
        // providerValidationRegex: String,
        
        productSku: String,
        receiverMobileNumber: String,
        settingsData: String,
        
        mobileNumber: String,
        serviceCode: String,
        iPayCustomerID: String,
        
        dismissMode: String
    ) {
        self.vm = EnterAmountViewModel(
            saveRecharge:saveRecharge,
            
            countryIso:countryIso,
            countryFlagUrl:countryFlagUrl,
            countryName:countryName,
            countryPrefix:countryPrefix,
            // countryMinimumLength:countryMinimumLength,
            // countryMaximumLength:countryMaximumLength,
            
            providerCode:providerCode,
            providerLogoUrl:providerLogoUrl,
            providerName:providerName,
            // providerValidationRegex:providerValidationRegex,
            
            productSku:productSku,
            receiverMobileNumber:receiverMobileNumber,
            settingsData:settingsData,
            
            mobileNumber:mobileNumber,
            serviceCode:serviceCode,
            iPayCustomerID:iPayCustomerID,
            
            dismissMode:dismissMode
        )
    }
    
    internal init(vm: EnterAmountViewModel) {
        self.vm = vm
    }
    
    public var body: some View {
        ZStack(alignment: .bottom){
            VStack (spacing: 0){
                Spacer().frame(height: 32)
                
                // Top Bar
                HStack {
                    Image("ic_back", bundle: .module)
                        .onTapGesture {
                            switch vm.dismissMode {
                            case "pop":
                                presentationMode.wrappedValue.dismiss()
                            case "closeSDK":
                                coord.dismissSDK()
                            default:
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
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
                    Text("Step 3 of 5")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Text("Enter amount to pay")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                //                Spacer().frame(height: 32)
                
                // Products list
                if vm.products.count == 1 {
                    SingleProductAmountEntryView(
                        vm: vm,
                        amount: $amount,
                        toastMessage: $toastMessage,
                        showToast: $showToast,
                       // sendValue: vm.selectedProduct?.sendValue!,
                       // sendValueMax: vm.selectedProduct?.sendValueMax!
                    )
                } else {
                    ProductsListView(vm: vm)
                }
                
                Spacer().frame(height: 32)
                
                Button(action: {
                    if(vm.products.count == 1) {
                        if let selectedProduct = vm.selectedProduct,
                           let min = Float(selectedProduct.sendValue),
                           let max = Float(selectedProduct.sendValueMax),
                           let entered = Float(amount),
                           !(min...max).contains(entered) {
                            toastMessage = "Amount must be between \(selectedProduct.sendValue) and \(selectedProduct.sendValueMax)"
                            showToast = true
                            return
                        }
                        showEnterUtility = true
                    }else{
                        showEnterUtility = true
                    }
                }) {
                    Text("Pay Bill")
                        .font(.custom("VodafoneRg-Bold", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(
                            Color(!disabledProceed ? "keyBs_bg_red_1" : "keyBs_bg_gray_1", bundle: .module)
                        )
                        .cornerRadius(60)
                        .padding(.horizontal, 16)
                }
                .disabled(disabledProceed)
                NavigationLink(
                    destination: Group {
                        if let p = vm.selectedProduct {
                            ReviewUtilityView(
                                saveRecharge:         vm.saveRecharge,
                                
                                countryIso:            vm.countryIso,
                                countryFlagUrl:        vm.countryFlagUrl,
                                countryName:           vm.countryName,
                                countryPrefix:         vm.countryPrefix,
                                
                                providerCode:          vm.providerCode,
                                providerLogoUrl:       vm.providerLogoUrl,
                                providerName:          vm.providerName,
                                
                                product:               p,
                                billAmount:          amount,
                                
                                receiverMobileNumber: vm.receiverMobileNumber,
                                settingsData: vm.settingsData,

                                mobileNumber:          vm.mobileNumber,
                                serviceCode:           vm.serviceCode,
                                iPayCustomerID:        vm.iPayCustomerID
                            )
                            .environmentObject(coord)
                            .navigationBarHidden(true)

                        }
                    },
                    isActive: $showEnterUtility,
                    label: { EmptyView() }
                )
                .hidden()
                .allowsHitTesting(false)     // ← add this line
                Image("bottom_pattern3", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)

            
        }
        .id(vm.products.count)
        .onAppear {
            Task { await vm.loadProducts() }
        }
        .onReceive(vm.$selectedProduct) {
            if $0 != nil && vm.products.count != 1 {
                disabledProceed = false
            } else {
                disabledProceed = true
            }
        }
        .onReceive(Just(amount)) { newValue in
            if(vm.products.count == 1){
                if(newValue == "0" || newValue.isEmpty){
                    disabledProceed = true
                }else{
                    disabledProceed = false
                }
            }
        }
        .onReceive(vm.$productsError) { msg in
            if let m = msg {
                toastMessage = m
                showToast    = true
            }
        }
        .onReceive(vm.$products) { products in
            productsCount = products.count
        }
        .toast(isShowing: $showToast, message: toastMessage)

        //.contentShape(Rectangle())
        //.onTapGesture {
        //    UIApplication.shared.endEditing()
        //}
        .sdkDismissKeyboardOnTap()
    }
    
    // MARK: – Products List View
    private struct ProductsListView: View {
        @ObservedObject var vm: EnterAmountViewModel
        
        var body: some View {
            Spacer().frame(height: 32)
            
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(vm.products) { p in
                        Button {
                            vm.selectedProduct = p
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(p.displayText)
                                        .font(.custom("VodafoneRg-Bold", size: 16))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("= \(p.sendCurrencyIso) \(p.sendValue)")
                                        .font(.custom(vm.selectedProduct?.skuCode == p.skuCode ? "VodafoneRg-Bold" : "VodafoneRg-Regular", size: 14))
                                        .foregroundColor(Color(vm.selectedProduct?.skuCode == p.skuCode ? "keyBs_font_red_1" : "keyBs_font_gray_3", bundle: .module))
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    if vm.selectedProduct?.skuCode == p.skuCode {
                                        Image("ic_selected_circle", bundle: .module)
                                            .frame(width: 32, height: 32)
                                            .scaledToFit()
                                    } else {
                                        Circle()
                                            .stroke(
                                                Color("keyBs_bg_gray_2", bundle: .module),
                                                lineWidth: 2
                                            )
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .scaledToFit()
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(
                            Color(
                                vm.selectedProduct?.skuCode == p.skuCode
                                ? "keyBs_bg_pink_1"
                                : "keyBs_white",
                                bundle: .module
                            )
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(
                                    Color(
                                        vm.selectedProduct?.skuCode == p.skuCode
                                        ? "keyBs_bg_red_1"
                                        : "keyBs_bg_gray_1",
                                        bundle: .module
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    
    // MARK: – Single Product Amount Entry View
    private struct SingleProductAmountEntryView: View {
        @ObservedObject var vm: EnterAmountViewModel
        @Binding var amount: String
        @Binding var toastMessage: String
        @Binding var showToast: Bool
       // @Binding var sendValue: String
       // @Binding var sendValueMax: String

        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                Text(
                    "Amount must be between \(vm.selectedProduct?.sendValue ?? "") and \(vm.selectedProduct?.sendValueMax ?? "")"
                )
                .font(.custom("VodafoneRg-Regular", size: 16))
                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 16)

                // Amount display
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(vm.selectedProduct?.sendCurrencyIso ?? "")
                        .font(.custom("VodafoneRg-Bold", size: 28))
                        .foregroundColor(Color(amount == "" ? "keyBs_bg_gray_1" : "keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    TextField("", text: $amount)
                        .font(.custom("VodafoneRg-Bold", size: 64))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: true, vertical: false)  // ← key line
                        .placeholder(when: amount.isEmpty) {
                            Text("0")
                                .font(.custom("VodafoneRg-Bold", size: 64))
                                .foregroundColor(Color("keyBs_bg_gray_1", bundle: .module))
                                .multilineTextAlignment(.leading)
                        }
                        .keyboardType(.numberPad)
                        .onReceive(Just(amount)) { newValue in
                            //var newAmount = amount == "0" ? newValue : amount + newValue
                            
                            // Limit to max value
                            if let max = Float(vm.selectedProduct?.sendValueMax ?? "0"),
                               let entered = Float(newValue),
                               entered > max {
                                // Do not update amount if over max
                                toastMessage = "Amount must be between \(vm.selectedProduct?.sendValue ?? "0") and \(vm.selectedProduct?.sendValueMax ?? "0")"
                                showToast = true
                                return
                            }
                            amount = newValue
                            //                                    let allFieldsFilled = product.settingDefinitions.allSatisfy {

                        }
                    /*
                    Text(amount.isEmpty ? "0" : amount)
                        .font(.custom("VodafoneRg-Bold", size: 64))
                        .foregroundColor(Color(amount == "0" ? "keyBs_bg_gray_1" : "keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                     */
                }
                .frame(maxWidth: .infinity, alignment: .center)   // ← centers the whole row


                Spacer()
                /*
                // Keypad
                NumberPad(
                    amount: $amount,
                    sendValue: vm.selectedProduct?.sendValue,
                    sendValueMax: vm.selectedProduct?.sendValueMax,
                    toastMessage: $toastMessage,
                    showToast: $showToast
                )
                 */
                
            }
            .padding(. horizontal, 16)
            .padding(.top, 16)

            
        }
    }
    
    // Simple number pad for amount entry
    private struct NumberPad: View {
        @Binding var amount: String
        var sendValue: String?
        var sendValueMax: String?
        @Binding var toastMessage: String
        @Binding var showToast: Bool
        
        let buttons: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [".", "0", "⌫"]
        ]
        
        var body: some View {
            VStack(spacing: 35) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                handleTap(
                                    item,
                                    sendValue: sendValue!,
                                    sendValueMax: sendValueMax!,
                                    toastMessage: &toastMessage,
                                    showToast: &showToast
                                )
                            }) {
                                Text(item)
                                    .font(.custom("VodafoneRg-Bold", size: 20))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .frame(maxWidth: .infinity)
                            }
                            // Make sure each button expands equally
                            .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
        
        private func handleTap(_ value: String, sendValue: String, sendValueMax: String, toastMessage: inout String, showToast: inout Bool) {
            switch value {
            case "⌫":
                if amount.count > 1 {amount.removeLast()} else {amount = "0"}
            case ".":
                if !amount.contains(".") { amount.isEmpty ? amount.append("0.") : amount.append(".")}
            default:
                var newAmount = amount == "0" ? value : amount + value
                
                // Limit to max value
                if let max = Float(sendValueMax),
                   let entered = Float(newAmount),
                   entered > max {
                    // Do not update amount if over max
                    toastMessage = "Amount must be between \(sendValue) and \(sendValueMax)"
                    showToast = true
                    return
                }
                amount = newAmount
            }
        }
    }
    
}
