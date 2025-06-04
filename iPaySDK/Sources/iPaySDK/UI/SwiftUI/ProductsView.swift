import SwiftUI

public struct ProductsView: View {
    @Environment(\.dismiss) private var pop
    @EnvironmentObject private var coord: SDKCoordinator
    
    @StateObject private var vm: ProductsViewModel
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var disabledProceed = true
    @State private var showReview = false
    
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
        _vm = StateObject(
            wrappedValue: ProductsViewModel(
                saveRecharge:saveRecharge,
                receiverMobileNumber:receiverMobileNumber,
                countryIso:countryIso,
                countryFlagUrl:countryFlagUrl,
                countryName:countryName,
                providerCode:providerCode,
                providerLogoUrl:providerLogoUrl,
                providerName:providerName,
                productSku:productSku,
                
                mobileNumber:mobileNumber,
                serviceCode:serviceCode,
                iPayCustomerID:iPayCustomerID,
                
                dismissMode:dismissMode
            )
        )
    }
    
    internal init(vm: ProductsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    public var body: some View {
        ZStack(alignment: .bottom){
            VStack (spacing: 0){
                Spacer().frame(height: 32)
                
                // Top Bar
                HStack {
                    Image("ic_back", bundle: .module)
                    //                        .onTapGesture { pop() }
                        .onTapGesture {
                            switch vm.dismissMode {
                            case "pop":
                                pop()
                            case "closeSDK":
                                coord.closeSDK()
                            default:
                                pop()
                            }
                        }
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
                    Text("Step 2 of 4")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Text("Select Top Up")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                // Products list
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(vm.products) { p in
                            Button {
                                vm.selectedProduct = p
                                // disabledProceed = false
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
                                        }else{
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
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(vm.selectedProduct?.skuCode == p.skuCode
                                                ? "keyBs_bg_pink_1" : "keyBs_white", bundle: .module))
                                    .stroke(
                                        Color(vm.selectedProduct?.skuCode == p.skuCode
                                              ? "keyBs_bg_red_1" : "keyBs_bg_gray_1", bundle: .module)
                                        ,
                                        lineWidth: 1
                                    )
                                    .shadow(color: Color.black.opacity(0.1),
                                            radius: 4, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer().frame(height: 32)
                
                Button(action: { showReview = true }) {
                    Text("Proceed")
                        .font(.custom("VodafoneRg-Bold", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .disabled(disabledProceed)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(
                            Color(!disabledProceed ? "keyBs_bg_red_1" : "keyBs_bg_gray_1", bundle: .module)
                        )
                        .cornerRadius(60)
                        .padding(.horizontal, 16)
                }
                .navigationDestination(isPresented: $showReview) {
                    if let p = vm.selectedProduct {
                        ReviewTopUpView(
                            saveRecharge:         vm.saveRecharge,
                            receiverMobileNumber:  vm.receiverMobileNumber,
                            countryIso:            vm.countryIso,
                            countryFlagUrl:        vm.countryFlagUrl,
                            countryName:           vm.countryName,
                            providerCode:          vm.providerCode,
                            providerLogoUrl:       vm.providerLogoUrl,
                            providerName:          vm.providerName,
                            product:               p,
                            
                            mobileNumber:          vm.mobileNumber,
                            serviceCode:           vm.serviceCode,
                            iPayCustomerID:        vm.iPayCustomerID
                        )
                        .toolbar(.hidden, for: .navigationBar)
                    }
                }
                
                // // Proceed Button
                // Button("Proceed") {
                //     showReview = true
                // }
                // .navigationDestination(isPresented: $showReview) {
                //     if let p = vm.selectedProduct {
                //         ReviewTopUpView(
                //             saveRecharge:         vm.saveRecharge,
                //             receiverMobileNumber:  vm.receiverMobileNumber,
                //             countryIso:            vm.countryIso,
                //             countryFlagUrl:        vm.countryFlagUrl,
                //             countryName:           vm.countryName,
                //             providerCode:          vm.providerCode,
                //             providerLogoUrl:       vm.providerLogoUrl,
                //             providerName:          vm.providerName,
                //             product:               p,
                
                //             mobileNumber:          vm.mobileNumber,
                //             serviceCode:           vm.serviceCode,
                //             iPayCustomerID:        vm.iPayCustomerID
                //         )
                //         .toolbar(.hidden, for: .navigationBar)
                //     }
                // }
                // .font(.custom("VodafoneRg-Bold", size: 16))
                // .foregroundColor(.white)
                // .multilineTextAlignment(.leading)
                // .disabled(disabledProceed)
                // .frame(maxWidth: .infinity, minHeight: 56)
                // .background(
                //     Color(!disabledProceed ? "keyBs_bg_red_1" : "keyBs_bg_gray_1", bundle: .module)
                // )
                // .cornerRadius(60)
                // .padding(.horizontal, 16)
                
                // Bottom pattern
                Image("bottom_pattern2", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            Task { await vm.loadProducts() }
        }
        .onReceive(vm.$selectedProduct) {
            if $0 != nil {
                disabledProceed = false
            } else {
                disabledProceed = true
            }
        }
        .onReceive(vm.$productsError) { msg in
            if let m = msg {
                toastMessage = m
                showToast    = true
            }
        }
        .toast(isShowing: $showToast, message: toastMessage)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}


#Preview {
    ProductsView(
        saveRecharge: "0",
        receiverMobileNumber: "45456456",
        countryIso: "AE",
        countryFlagUrl: URL(string: "http://keybs.ai/fg/ae.svg")!,
        countryName: "United Arab Emirates",
        providerCode: "E6AE",
        providerLogoUrl: URL(string: "https://imagerepo.ding.com/logo/DU/AE.png")!,
        providerName: "DU UAE",
        productSku: "",
        
        mobileNumber: "88776630",
        serviceCode: "INT_TOP_UP",
        iPayCustomerID: "13",
        
        dismissMode: "pop"
    )
}

struct ProductsView_PreviewsData: PreviewProvider {
    static var previews: some View {
        // Mock ProductsViewModel with sample products
        let mockProducts = [
            ProductItem(skuCode: "E6AEAE12938", providerCode: "E6AE", countryIso: "AE", displayText: "AED 20.00", sendValue: "28", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE17155", providerCode: "E6AE", countryIso: "AE", displayText: "AED 50.00", sendValue: "69.6", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE17343", providerCode: "E6AE", countryIso: "AE", displayText: "AED 25.00", sendValue: "34.8", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE17361", providerCode: "E6AE", countryIso: "AE", displayText: "AED 5.00", sendValue: "7", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE22430", providerCode: "E6AE", countryIso: "AE", displayText: "AED 10.00", sendValue: "14.1", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE25659", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 25 (400MB Data)", sendValue: "34.8", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE33503", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 210 (8 GB Data)", sendValue: "292.4", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE35243", providerCode: "E6AE", countryIso: "AE", displayText: "AED 45.00", sendValue: "62.8", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE35435", providerCode: "E6AE", countryIso: "AE", displayText: "AED 300.00", sendValue: "416.7", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE46146", providerCode: "E6AE", countryIso: "AE", displayText: "AED 30.00", sendValue: "41.9", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE46729", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 525 (40 GB Data)", sendValue: "731.1", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE53289", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 110 (2.2 GB Data)", sendValue: "153.3", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE64011", providerCode: "E6AE", countryIso: "AE", displayText: "AED 40.00", sendValue: "55.7", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE73090", providerCode: "E6AE", countryIso: "AE", displayText: "AED 200.00", sendValue: "278.5", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE73954", providerCode: "E6AE", countryIso: "AE", displayText: "AED 35.00", sendValue: "48.9", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE81767", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 55 (1GB Data)", sendValue: "76.7", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE8527", providerCode: "E6AE", countryIso: "AE", displayText: "AED 15.00", sendValue: "20.9", sendCurrencyIso: "QR"),
            ProductItem(skuCode: "E6AEAE94772", providerCode: "E6AE", countryIso: "AE", displayText: "AED 100.00", sendValue: "139.3", sendCurrencyIso: "QR")
        ]
        
        let vm = ProductsViewModel(
            saveRecharge: "0",
            receiverMobileNumber: "45456456",
            countryIso: "AE",
            countryFlagUrl: URL(string: "http://keybs.ai/fg/ae.svg")!,
            countryName: "United Arab Emirates",
            providerCode: "E6AE",
            providerLogoUrl: URL(string: "https://imagerepo.ding.com/logo/DU/AE.png")!,
            providerName: "DU UAE",
            productSku: "",
            
            mobileNumber: "88776630",
            serviceCode: "INT_TOP_UP",
            iPayCustomerID: "13",
            
            dismissMode: "pop"
        )
        vm.products = mockProducts
        
        return ProductsView(vm: vm)
            .previewLayout(.sizeThatFits)
    }
}
