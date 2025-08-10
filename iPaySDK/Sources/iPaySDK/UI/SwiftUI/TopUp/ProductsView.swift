import SwiftUI
import Combine


public struct ProductsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: ProductsViewModel
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var disabledProceed = true
    @State private var showReview = false
    @State private var search: String = ""

    @State private var selectedSection = 0
    
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
        self.vm = ProductsViewModel(
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
    }
    
    internal init(vm: ProductsViewModel) {
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
                
                // Section Tabs
                if(!vm.products.isEmpty) {
                    HStack(spacing: 8) {
                        if(!vm.products.filter{ $0.classification != "2" }.isEmpty) {
                            Button(action: {
                                selectedSection = 1
                                vm.selectedClass = "1"
                                vm.filteredProducts = vm.products.filter { $0.classification != "2" }
                            }) {
                                Text("Airtime Topup")
                                    .font(.custom(selectedSection == 1 ? "VodafoneRg-Bold" : "VodafoneRg-Regular", size: 14))
                                    .foregroundColor(Color(selectedSection == 1 ? "keyBs_white" : "keyBs_font_gray_2", bundle: .module))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(Color(selectedSection == 1 ? "keyBs_bg_red_1" : "keyBs_bg_gray_6", bundle: .module))
                                    .cornerRadius(40)
                            }
                        }
                        
                        if(!vm.products.filter{ $0.classification == "2" }.isEmpty) {
                            Button(action: {
                                selectedSection = 2
                                vm.selectedClass = "2"
                                vm.filteredProducts = vm.products.filter { $0.classification == "2" }
                                //vm.filterProducts(by: "")

                            }) {
                                Text("Plan")
                                    .font(.custom(selectedSection == 2 ? "VodafoneRg-Bold" : "VodafoneRg-Regular", size: 14))
                                    .foregroundColor(Color(selectedSection == 2 ? "keyBs_white" : "keyBs_font_gray_2", bundle: .module))
                                    .padding(.vertical, 9)
                                    .padding(.horizontal, 16)
                                    .background(Color(selectedSection == 2 ? "keyBs_bg_red_1" : "keyBs_bg_gray_6", bundle: .module))
                                    .cornerRadius(40)
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 32)
                }
                
                
                if selectedSection != 2 {
                    
                    // Products list
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(vm.filteredProducts) { p in
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
                                    .buttonStyle(.plain)

                            }

                            
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
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(
                                Color(!disabledProceed ? "keyBs_bg_red_1" : "keyBs_bg_gray_1", bundle: .module)
                            )
                            .cornerRadius(60)
                            .padding(.horizontal, 16)
                    }
                    .disabled(disabledProceed)
                    Image("bottom_pattern3", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    
                } else if selectedSection == 2 {
                    HStack(spacing: 8) {
                        Image("ic_search", bundle: .module)
                            .frame(width: 16, height: 16)
                            .scaledToFit()
                        
                        TextField("Search", text: $vm.searchText)
                            .foregroundColor(.primary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color("keyBs_white", bundle: .module))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("keyBs_bg_gray_1", bundle: .module), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)

                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(vm.filteredProducts) { p in
                                Button {
                                    vm.selectedProduct = p
                                    showReview = true
                                    // print("Product: \(p)")
                                } label: {
                                    VStack(spacing: 0) {
                                        // Top Red Bar with Price
                                        HStack {
                                            Text(p.displayText)
                                                .font(.custom("VodafoneRg-Bold", size: 18))
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(LinearGradient(
                                            stops: [
                                                Gradient.Stop(color: Color(red: 159.0 / 255.0, green: 0.0, blue: 0.0), location: 0.0),
                                                Gradient.Stop(color: Color(red: 83.0 / 255.0, green: 0.0, blue: 0.0), location: 1.0)],
                                            startPoint: .leading,
                                            endPoint: .trailing))
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0.5)
                                                .stroke(Color(white: 235.0 / 255.0), lineWidth: 1.0)
                                        )                                        .cornerRadius(12, corners: [.topLeft, .topRight])
                                        
                                        // Bottom White Section with Display Text and Subtitle
                                        VStack(alignment: .leading, spacing: 6) {
                                            
                                            Text(p.descriptionMarkdown ?? "")
                                                .font(.custom("VodafoneRg-Bold", size: 14))
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        }
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color.gray.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )
                                    
                                }
                                .padding(.horizontal, 8)
                                //.padding(.vertical, 12)
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                    }
                    .padding(.bottom,20)
                    Spacer().frame(height: 32)

                    
                }
                
               
                NavigationLink(
                    destination: Group {
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
                            .environmentObject(coord)
                            .navigationBarHidden(true)
                        }
                    },
                    isActive: $showReview,
                    label: { EmptyView() }
                )
                .hidden()
                
                // Bottom pattern

            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            Task {

                if (!vm.productsLoaded) {
                    await vm.loadProducts()
                }
                if(vm.selectedProduct != nil) {
                    print("product: \(vm.selectedProduct)")
                    selectedSection = vm.selectedProduct?.classification == "2" ? 2 : 1
                    vm.selectedClass = vm.selectedProduct?.classification == "2" ? "2" : "1"
                    vm.filteredProducts = vm.products.filter{ $0.classification == vm.selectedProduct?.classification }
                }else{
                    //await vm.loadProducts()
                    // Default to Airtime Topup
                    
                    selectedSection = 1
                    vm.selectedClass = "1"
                    vm.filteredProducts = vm.products.filter { $0.classification == "1" }
                    if(vm.filteredProducts.isEmpty) {
                        // If no Airtime Topup, then show Plan

                        selectedSection = 2
                        vm.selectedClass = "2"
                        vm.filteredProducts = vm.products.filter { $0.classification == "2" }

                    }
                     
                }
            }
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
