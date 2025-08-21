import SwiftUI
import Combine
import ContactsUI
import UIKit
import SDWebImageSwiftUI


public struct UtilityView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: UtilityViewModel
    
    @State private var tab: UtilityTabView.Tab = .new
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var showDeletionModal = false
    @State private var deletionMessage = ""
        
    @State private var country: CountryItem?
    @State private var showPicker = false
    
    @State private var showProviders = true
    @State private var showProvidersList = false
    @State private var selectedProvider: ProviderItem?
    
    @State private var disabledProceed = true
    @State private var showProducts = false
    
    @State private var selectedSavedBill: SavedBillsItem?
    
    // a merged publisher of both error streams
    private var errorStream: AnyPublisher<String?, Never> {
        Publishers.Merge3(vm.$countriesError, vm.$providersError, vm.$savedBillsError)
            .eraseToAnyPublisher()
    }
    
    public init (
        mobileNumber: String,
        serviceCode:  String,
        iPayCustomerID: String
    ) {
        self.vm = UtilityViewModel(
            serviceCode: serviceCode,
            mobileNumber: mobileNumber,
            iPayCustomerID: iPayCustomerID
        )
    }
    
    public var body: some View {
        // NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 32)
                    
                    // Top Bar
                    HStack {
                        Image("ic_back", bundle: .module)
                            // .onTapGesture { presentationMode.wrappedValue.dismiss() }
                            .onTapGesture { coord.dismissSDK() }
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
                        Text("Step 1 of 5")
                            .font(.custom("VodafoneRg-Regular", size: 16))
                            .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Text("Pay International Utility Bill")
                            .font(.custom("VodafoneRg-Bold", size: 20))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 75)
                    
                    // Tabs
                    UtilityTabView(selection: $tab)
                    
                    // Content
                    if tab == .new {
                        newUtilityView
                    } else {
                        savedUtilityView
                    }
                }
                .background(Color.white)
                
                if showDeletionModal {
                    DeletionSuccessModalView(
                        isPresented: $showDeletionModal,
                        message:      deletionMessage,
                        onHomepage: {
                            showDeletionModal = false
                            deletionMessage = ""
                            vm.deleteSuccessMessage = ""
                        }
                    )
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                CountryPicker(
                    vm: vm
                ) { selectedCountry in
                    country = selectedCountry
                    
                    Task {
                        await vm.loadProviders(for: selectedCountry.countryIso)
                        
                        if(vm.providers.count == 1){
                            selectedProvider = vm.providers.first
                            showProvidersList = false
                            disabledProceed = false
                        }else{
                            selectedProvider = nil
                            showProvidersList = false
                            disabledProceed = true
                        }
                        
                    }
                }
            }
            .onAppear {
                Task { await vm.loadCountries() }
                Task { await vm.loadSavedBills() }
            }
            .onReceive(errorStream) { msg in
                if let m = msg {
                    toastMessage = m
                    showToast    = true
                }
            }
            .toast(isShowing: $showToast, message: toastMessage)
            //.contentShape(Rectangle())
            //.onTapGesture {
            //    UIApplication.shared.endEditing()
            //}
            //.sdkDismissKeyboardOnTap()    // ← add this, and delete the old onTapGesture

        // }
    }
    
    // MARK: – New Utility Tab
    private var newUtilityView: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 64)
                
                // Country Field
                VStack(spacing: 8) {
                    if country != nil {
                        Text("Country")
                            .font(.custom("VodafoneRg-Regular", size: 16.0))
                            .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        showPicker = true
                    } label: {
                        HStack(spacing: 16) {
                            if let c = country {
                                SVGImageView(url: c.flagUrl)
                                    .frame(width: 16, height: 16)
                                    .scaledToFit()
                                    .cornerRadius(16)
                                
                                Text(c.name)
                                    .font(.custom("VodafoneRg-Bold", size: 16.0))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("Country")
                                    .font(.custom("VodafoneRg-Regular", size: 16.0))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            Image("ic_chevron_down", bundle: .module)
                                .frame(width: 20, height: 20)
                                .scaledToFit()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 16)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color("keyBs_bg_gray_1", bundle: .module)),
                        alignment: .bottom
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                ZStack(alignment: .top) {
                    // Operator Dropdown
                    VStack(spacing: 8) {
                        if selectedProvider != nil {
                            Text("Select Utility")
                                .font(.custom("VodafoneRg-Regular", size: 16.0))
                                .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Dropdown header
                        VStack(spacing: 0) {
                            Button {
                                showProvidersList.toggle()
                            } label: {
                                HStack(spacing: 16) {
                                    if let p = selectedProvider {
                                        // loaded logo
                                        RemoteImage(
                                            url: p.logoUrl,
                                            placeholder: AnyView(Color.gray.opacity(0.3))
                                        )
                                        .aspectRatio(contentMode: .fit) // maintain aspect ratio
                                        .frame(
                                                width: 16,
                                                height:16,
                                                alignment: .leading
                                            )
                                        Text(p.name)
                                            .font(.custom("VodafoneRg-Bold", size: 16.0))
                                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                            .multilineTextAlignment(.leading)
                                    } else {
                                        Text("Select Utility")
                                            .font(.custom("VodafoneRg-Regular", size: 16.0))
                                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(showProvidersList ? "ic_chevron_up" : "ic_chevron_down", bundle: .module)
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .frame(width: 20, height: 20)
                                        .scaledToFit()
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 16)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color("keyBs_bg_gray_1", bundle: .module)),
                                alignment: .bottom
                            )
                        }
                        .zIndex(0)
                        
                        // The dropdown list
                        if showProvidersList {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(vm.providers) { p in
                                        Button {
                                            selectedProvider = p
                                            showProvidersList = false
                                            disabledProceed = false
                                        } label: {
                                            VStack(spacing: 0) {
                                                HStack(spacing: 16) {
                                                    RemoteImage(
                                                        url: p.logoUrl,
                                                        placeholder: AnyView(Color.gray.opacity(0.3))
                                                    )
                                                    .aspectRatio(contentMode: .fit) // maintain aspect ratio
                                                    .frame(
                                                                                width: 16,
                                                                                height:16,
                                                                                alignment: .leading
                                                                            )
                        
                                                    Text(p.name)
                                                        .font(.custom("VodafoneRg-Regular", size: 16))
                                                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                                                        .multilineTextAlignment(.leading)
                                                }
                                                .padding(.all, 16)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(
                                                    selectedProvider?.providerCode == p.providerCode
                                                    ? Color("keyBs_bg_pink_1", bundle: .module)
                                                    : Color.white
                                                )
                                                
                                                if p.providerCode != vm.providers.last?.providerCode {
                                                    Divider()
                                                        .overlay(Color("keyBs_bg_gray_1", bundle: .module))
                                                        .padding(.horizontal, 16)
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(
                                maxHeight: min(CGFloat(vm.providers.count) * 56, 300)
                            )
                            .cornerRadius(8, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.3),
                                            radius: 4, x: 0, y: 2)
                            )
                            .offset(y: 0)
                            .zIndex(1)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                Button(action: {
                    showProducts = true
                }) {
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
                NavigationLink(
                    destination: Group {
                        if let c = country,
                           let p = selectedProvider
                        {
                            EnterUtilityDetailsView(
                                saveRecharge:         "1",
                                
                               countryIso: c.countryIso,
                               countryFlagUrl: c.flagUrl,
                               countryName: c.name,
                               countryPrefix: c.prefix,
                               countryMinimumLength: c.minimumLength,
                               countryMaximumLength: c.maximumLength,
                               
                               providerCode: p.providerCode,
                               providerLogoUrl: p.logoUrl,
                               providerName: p.name,
                               providerValidationRegex: p.validationRegex,
                                
                                // product:               p,
                                // billAmount:          amount,

                                settingDefinitions: p.settingDefinitions,
                                
                                mobileNumber:          vm.mobileNumber,
                                serviceCode:           vm.serviceCode,
                                iPayCustomerID:        vm.iPayCustomerID
                            )
                            .environmentObject(coord)
                            .navigationBarHidden(true)
                        }
                    },
                    isActive: $showProducts,
                    label: { EmptyView() }
                )
                .hidden()
                .allowsHitTesting(false)     // ← add this line

                
                // Bottom pattern
                Image("bottom_pattern3", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .background(Color.white)
            .cornerRadius(50, corners: [.topLeft])
            .edgesIgnoringSafeArea(.all)
        }
        .background(Color("keyBs_bg_red_tabs", bundle: .module))
        .sdkDismissKeyboardOnTap()

    }
    
    //    ----------------------
    
    // MARK: – Saved Top-Up Tab
    private var savedUtilityView: some View {
        return ZStack {
            VStack(spacing: 0) {
                if vm.savedBills.isEmpty {
                    Spacer().frame(height: 20)
                    
                    //LottieView(name: "utility_no_bills", bundle: .module)
                    //    .frame(width: 200, height: 200)
                    let url = Bundle.module.url(forResource: "utility_no_bills", withExtension: "gif")

                    AnimatedImage(url: url)
                                               .resizable()
                                               .scaledToFit()
                                               .frame(height: 300)
                        /*
                                           AnimatedImage(url: url)
                                               .resizable()
                                               .scaledToFit()
                                               .frame(height: 220)
                         */

                   // }
                     
                    /*
                    Spacer().frame(height: 26)
                    
                    VStack(spacing: 8) {
                        Text("No Voucher Yet")
                            .font(.custom("VodafoneRg-Bold", size: 28))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Text("Do a transaction to get started")
                            .font(.custom("VodafoneRg-Regular", size: 18))
                            .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                     */
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(vm.savedBills) { bill in
                                SavedBillRow(
                                    bill: bill,
                                    onTap: {
                                        // print("Select bill: \(bill)")
                                        selectedSavedBill = bill
                                        showProducts = true
                                    },
                                    onDelete: {
                                        Task {
                                            await vm.deleteSavedBill(bill)
                                        }
                                    }
                                )
                                .overlay(
                                    bill.id != vm.savedBills.last?.id ?
                                    AnyView(
                                        DashedDivider()
                                            .padding(.horizontal, 16)
                                    ) : AnyView(EmptyView()),
                                    alignment: .bottom
                                )
                                
                            }
                            NavigationLink(
                                destination: Group {
                                    if let c = selectedSavedBill {
                                        EnterAmountView(
                                            saveRecharge: "1",
                                                                            
                                            countryIso: c.countryIso2,
                                            countryFlagUrl: c.countryFlagUrl,
                                            countryName: c.countryName,
                                            countryPrefix: c.countryPrefix ?? "",
                                            // countryMinimumLength: c.countryMinimumLength ?? "" ,
                                            // countryMaximumLength: c.countryMaximumLength ?? "",
                                            
                                            providerCode: c.providerCode,
                                            providerLogoUrl: c.providerImgUrl,
                                            providerName: c.providerName,
                                            // providerValidationRegex: c.providerValidationRegex ?? "",
                                            
                                            productSku: c.productSku,
                                            receiverMobileNumber: c.targetIdentifier,
                                            settingsData: c.settingsData ?? "",
                                            
                                            mobileNumber: vm.mobileNumber,
                                            serviceCode:  vm.serviceCode,
                                            iPayCustomerID: vm.iPayCustomerID,
                                            
                                            dismissMode: "pop"
                                        )
                                        .environmentObject(coord)
                                        .navigationBarHidden(true)
                                    }
                                },
                                isActive: $showProducts,
                                label: { EmptyView() }
                            )
                            .hidden()
                            .allowsHitTesting(false)     // ← add this line

                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(50, corners: [.topRight])
            .edgesIgnoringSafeArea(.all)
        }
        .background(Color("keyBs_bg_red_tabs", bundle: .module))
        .onReceive(vm.$deleteSuccessMessage) { msg in
            if let msg  {
                if msg != "" {
                    deletionMessage   = msg
                    showDeletionModal = true
                }
            }
        }
        //  .onAppear {
        //      Task { await vm.loadSavedBills() }
        //  }
    }
    
    /// One row in the “Saved Top-Up” list
    private struct SavedBillRow: View {
        let bill: SavedBillsItem
        let onTap: () -> Void
        let onDelete: () -> Void
        
        @State private var offsetX: CGFloat = 0
        @State private var isOpen: Bool = false
        
        // The width of the delete button area
        private let deleteWidth: CGFloat = 90
        
        var body: some View {
            ZStack(alignment: .trailing) {
                // Main content
                Button(action: {
                    if !isOpen {
                        onTap()
                    } else {
                        withAnimation {
                            offsetX = 0
                            isOpen = false
                        }
                    }
                }) {
                    HStack(spacing: 16) {
                        VStack{
                            SVGImageView(url: bill.countryFlagUrl)
                                .frame(width: 30, height: 30)
                                .scaledToFit()
                                .cornerRadius(15)
                        }
                        .frame(width: 48, height: 48)
                        .background(Color("keyBs_bg_gray_4", bundle: .module))
                        .cornerRadius(16)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bill.targetIdentifierSetting != nil ? bill.targetIdentifierSetting! : bill.targetIdentifier)
                                .font(.custom("VodafoneRg-Bold", size: 16))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                            
                            Text(bill.providerName)
                                .font(.custom("VodafoneRg-Regular", size: 14))
                                .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 31)
                    .background(Color.white)
                }
                .buttonStyle(.plain)
            }
            .clipped()
        }
    }
}

/// A dashed horizontal divider
private struct DashedDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                p.move(to: .zero)
                p.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(
                lineWidth: 1,
                dash: [6, 4]
            ))
            .foregroundColor(Color("keyBs_bg_gray_2", bundle: .module).opacity(0.3))
        }
        .frame(height: 1)
    }
}

#Preview {
    UtilityView(
        mobileNumber: "88776630",
        serviceCode:  "INT_TOP_UP",
        iPayCustomerID: "13"
    )
}
