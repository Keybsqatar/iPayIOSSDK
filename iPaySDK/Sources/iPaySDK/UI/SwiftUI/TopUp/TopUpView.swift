import SwiftUI
import Combine
import ContactsUI
import UIKit

public struct TopUpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: TopUpViewModel
    
    @State private var showDeletionModal = false
    @State private var deletionMessage = ""
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var tab: TopUpTabView.Tab = .new
    
    @State private var phone = ""
    @State private var contactDelegate = ContactDelegate()
    
    @State private var saveRecharge = true
    
    @State private var country: CountryItem?
    @State private var showPicker = false
    
    @State private var showProviders = false
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
        self.vm = TopUpViewModel(
            serviceCode: serviceCode,
            mobileNumber: mobileNumber,
            iPayCustomerID: iPayCustomerID
        )
    }
    
    private struct HideSeparatorAndBackground: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 15.0, *) {
                content
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.white)
            } else {
                content
            }
        }
    }
    
    public var body: some View {
        NavigationView {
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
                            .onTapGesture { coord.closeSDK() }
                            .frame(width: 24, height: 24)
                            .scaledToFit()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 24)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step 1 of 4")
                            .font(.custom("VodafoneRg-Regular", size: 16))
                            .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Text("Top Up International Number")
                            .font(.custom("VodafoneRg-Bold", size: 20))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 75)
                    
                    // Tabs
                    TopUpTabView(selection: $tab)
                    
                    // Content
                    if tab == .new {
                        newTopUpView
                    } else {
                        savedTabView
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
            .sheet(isPresented: $showPicker) {
                CountryPicker(
                    vm: vm
                ) { selectedCountry in
                    country = selectedCountry
                    
                    vm.mobileMaxLength = (Int(selectedCountry.maximumLength) ?? 0) - selectedCountry.prefix.count
                    vm.mobileMinLength = (Int(selectedCountry.minimumLength) ?? 0) - selectedCountry.prefix.count
                    
                    if !phone.isEmpty {
                        cleanAndSetPhone(selected: phone)
                    }
                    
                    if(!showProviders){
                        if(!phone.isEmpty) {
                            disabledProceed = false
                        } else {
                            disabledProceed = true
                        }
                    }else{
                        Task {
                            await vm.loadProviders(for: selectedCountry.countryIso)
                        }
                        selectedProvider = nil
                        showProviders = true
                        disabledProceed = true
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
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    // MARK: – New Top-Up Tab
    private var newTopUpView: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 64)
                
                HStack(spacing: 16) {
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
                                    
                                    Text("+\(c.prefix)")
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
                    
                    // ─── Phone Field ────────────────────────────────────────────
                    VStack(spacing: 8) {
                        if phone != "" {
                            Text("Mobile Number")
                                .font(.custom("VodafoneRg-Regular", size: 16.0))
                                .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack {
                            TextField("", text: $phone)
                                .font(.custom("VodafoneRg-Bold", size: 16.0))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .placeholder(when: phone.isEmpty) {
                                    Text("Mobile Number")
                                        .font(.custom("VodafoneRg-Regular", size: 16.0))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .multilineTextAlignment(.leading)
                                }
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity)
                                .onReceive(Just(phone)) { newValue in
                                    if(!showProviders){
                                        if(country != nil && !newValue.isEmpty) {
                                            disabledProceed = false
                                        } else {
                                            disabledProceed = true
                                        }
                                    }
                                }
                            
                            Button {
                                presentContactPicker()
                            } label: {
                                Image("ic_phone", bundle: .module)
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
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 47.5)
                
                if(showProviders){
                    ZStack(alignment: .top) {
                        // Operator Dropdown
                        VStack(spacing: 8) {
                            if selectedProvider != nil {
                                Text("Select operator name")
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
                                            .frame(width: 16, height: 16)
                                            
                                            Text(p.name)
                                                .font(.custom("VodafoneRg-Bold", size: 16.0))
                                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                                .multilineTextAlignment(.leading)
                                        } else {
                                            Text("Select operator name")
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
                                                        .frame(width: 16, height: 16)
                                                        
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
                            // if showProvidersList {
                            //     // VStack(spacing: 0) {
                            //     List {
                            //         ForEach(vm.providers) { p in
                            //             Button {
                            //                 selectedProvider = p
                            //                 showProvidersList = false
                            //                 disabledProceed = false
                            //             } label: {
                            //                 VStack(spacing: 0) {
                            //                     HStack(spacing: 16) {
                            //                         // AsyncImage(url: p.logoUrl) { phase in
                            //                         //     if case .success(let img) = phase {
                            //                         //         img.resizable().scaledToFit()
                            //                         //     } else {
                            //                         //         Color.gray.opacity(0.3)
                            //                         //     }
                            //                         // }
                            //                         RemoteImage(
                            //                             url: p.logoUrl,
                            //                             placeholder: AnyView(Color.gray.opacity(0.3))
                            //                         )
                            //                         .frame(width: 16, height: 16)
                            
                            //                         Text(p.name)
                            //                             .font(.custom("VodafoneRg-Regular", size: 16))
                            //                             .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            //                             .multilineTextAlignment(.leading)
                            //                     }
                            //                     .padding(.all, 16)
                            //                     .frame(maxWidth: .infinity, alignment: .leading)
                            //                     .background(
                            //                         selectedProvider?.providerCode == p.providerCode
                            //                         ? Color("keyBs_bg_pink_1", bundle: .module)
                            //                         : Color.white
                            //                     )
                            
                            //                     if p.providerCode != vm.providers.last?.providerCode {
                            //                         Divider()
                            //                             .overlay(Color("keyBs_bg_gray_1", bundle: .module))
                            //                             .padding(.horizontal, 16)
                            //                     }
                            //                 }
                            //             }
                            //             .listRowInsets(EdgeInsets())
                            //             // .listRowInsets(EdgeInsets())
                            //             //                                        if #available(iOS 14.0, *) {
                            //             //                                            listRowInsets(EdgeInsets())
                            //             //                                        }
                            //             //                                        // .listRowSeparator(.hidden)
                            //             //                                        if #available(iOS 15.0, *) {
                            //             //                                            listRowSeparator(.hidden)
                            //             //                                        }
                            //             .buttonStyle(.plain)
                            //         }
                            //     }
                            //     .listStyle(.plain)
                            //     .frame(
                            //         maxHeight: min(CGFloat(vm.providers.count) * 56, 300)
                            //     ) // 56 is estimated row height, 300 is max height for scroll
                            //     //                                .listRowInsets(EdgeInsets())
                            //     //                                .listRowSeparator(.hidden)
                            //     // }
                            //     .cornerRadius(8, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                            //     .background(
                            //         RoundedRectangle(cornerRadius: 8)
                            //             .fill(Color.white)
                            //             .shadow(color: Color.black.opacity(0.3),
                            //                     radius: 4, x: 0, y: 2)
                            //     )
                            //     .offset(y: 0) // <-- Adjust this value to position the dropdown
                            //     .zIndex(1)
                            // }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                Spacer()
                
                // Checkbox
                HStack(spacing: 16) {
                    Button(action: { saveRecharge.toggle() }) {
                        Image(
                            saveRecharge ? "ic_checkbox_checked" : "ic_checkbox_unchecked",
                            bundle: .module
                        )
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                    }
                    
                    Text("Save my recharges")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 25)
                
                Button(action: {
                    if (phone.count < vm.mobileMinLength) || (phone.count > vm.mobileMaxLength) {
                        toastMessage = "Mobile number must be between \(vm.mobileMinLength) and \(vm.mobileMaxLength) digits."
                        showToast = true
                        return
                    }
                    
                    if(!showProviders){
                        Task {
                            if let c = country {
                                await vm.loadProviders(for: c.countryIso)
                                showProviders = true
                                disabledProceed = true
                            }
                        }
                    }else{
                        let regexPattern = selectedProvider?.validationRegex ?? ""
                        let fullReceiverMobileNumber = (country?.prefix ?? "") + phone
                        
                        if !regexPattern.isEmpty {
                            if fullReceiverMobileNumber.range(of: regexPattern, options: .regularExpression) == nil {
                                toastMessage = "Invalid mobile number format for the selected provider."
                                showToast = true
                                return
                            }
                        }
                        
                        showProducts = true
                    }
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
                            ProductsView(
                                saveRecharge: saveRecharge ? "1" : "0",
                                receiverMobileNumber: phone,
                                countryIso: c.countryIso,
                                countryFlagUrl: c.flagUrl,
                                countryName: c.name,
                                providerCode: p.providerCode,
                                providerLogoUrl: p.logoUrl,
                                providerName: p.name,
                                productSku: "",
                                mobileNumber: vm.mobileNumber,
                                serviceCode:  vm.serviceCode,
                                iPayCustomerID: vm.iPayCustomerID,
                                dismissMode: "pop"
                            )
                            .navigationBarHidden(true)
                        }
                    },
                    isActive: $showProducts,
                    label: { EmptyView() }
                )
                .hidden()
                
                // Bottom pattern
                Image("bottom_pattern2", bundle: .module)
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
    }
    
    class ContactDelegate: NSObject, CNContactPickerDelegate {
        var onSelect: (String) -> Void = { _ in }
        func contactPicker(_ picker: CNContactPickerViewController,
                           didSelect contactProperty: CNContactProperty) {
            if let num = contactProperty.value as? CNPhoneNumber {
                let digits = num.stringValue
                    .components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined()
                onSelect(digits)
            }
        }
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            // nothing else: CNContactPicker dismisses itself
        }
    }
    
    private func presentContactPicker() {
        contactDelegate.onSelect = { selected in
            cleanAndSetPhone(selected: selected)
        }
        
        DispatchQueue.main.async {
            guard let top = UIApplication.topViewController() else { return }
            let picker = CNContactPickerViewController()
            picker.delegate = contactDelegate
            picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            top.present(picker, animated: true)
        }
    }
    
    private func cleanAndSetPhone(selected: String) {
        if let selectedCountry = country {
            var cleanedPhone = selected
            let mobileMaxLength = vm.mobileMaxLength
            if cleanedPhone.count > mobileMaxLength {
                let prefix = selectedCountry.prefix
                if !prefix.isEmpty {
                    let prefixWithZeros = "00" + prefix
                    if cleanedPhone.hasPrefix(prefix) {
                        cleanedPhone = String(cleanedPhone.dropFirst(prefix.count))
                    } else if cleanedPhone.hasPrefix(prefixWithZeros) {
                        cleanedPhone = String(cleanedPhone.dropFirst(prefixWithZeros.count))
                    }
                }
            }
            phone = cleanedPhone
        } else {
            phone = selected
        }
    }
    
    //    ----------------------
    
    // MARK: – Saved Top-Up Tab
    private var savedTabView: some View {
        return ZStack {
            VStack(spacing: 0) {
                if vm.savedBills.isEmpty {
                    Spacer().frame(height: 96)
                    
                    Image("keybs_empty_saved_topups", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 235, height: 220)
                    
                    Spacer().frame(height: 26)
                    
                    VStack(spacing: 8) {
                        Text("No Top up Yet")
                            .font(.custom("VodafoneRg-Bold", size: 28))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Text("Do a transaction to get started")
                            .font(.custom("VodafoneRg-Regular", size: 18))
                            .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(vm.savedBills) { bill in
                                SavedBillRow(
                                    bill: bill,
                                    onTap: {
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
                                        ProductsView(
                                            saveRecharge: "0",
                                            receiverMobileNumber: c.targetIdentifier,
                                            countryIso: c.countryIso2,
                                            countryFlagUrl: c.countryFlagUrl,
                                            countryName: c.countryName,
                                            providerCode: c.providerCode,
                                            providerLogoUrl: c.providerImgUrl,
                                            providerName: c.providerName,
                                            productSku: c.productSku,
                                            mobileNumber: vm.mobileNumber,
                                            serviceCode:  vm.serviceCode,
                                            iPayCustomerID: vm.iPayCustomerID,
                                            dismissMode: "pop"
                                        )
                                        .navigationBarHidden(true)
                                    }
                                },
                                isActive: $showProducts,
                                label: { EmptyView() }
                            )
                            .hidden()
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
                // Delete button background
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            offsetX = 0
                            isOpen = false
                        }
                        onDelete()
                    }) {
                        Image("ic_delete", bundle: .module)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Color("keyBs_bg_gray_4", bundle: .module))
                            .cornerRadius(12)
                    }
                    .frame(width: deleteWidth, height: 60)
                    .padding(.trailing, 16)
                }
                
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
                                .cornerRadius(30)
                        }
                        .frame(width: 48, height: 48)
                        .background(Color("keyBs_bg_gray_4", bundle: .module))
                        .cornerRadius(16)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bill.targetIdentifier)
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
                .offset(x: offsetX)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow left swipe, clamp to -deleteWidth
                            if value.translation.width < 0 {
                                offsetX = max(value.translation.width, -deleteWidth)
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -deleteWidth / 2 {
                                    offsetX = -deleteWidth
                                    isOpen = true
                                } else {
                                    offsetX = 0
                                    isOpen = false
                                }
                            }
                        }
                    
                )
                .animation(.easeOut(duration: 0.2), value: offsetX)
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
    TopUpView(
        mobileNumber: "88776630",
        serviceCode:  "INT_TOP_UP",
        iPayCustomerID: "13"
    )
}

//struct TopUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopUpView(
//            mobileNumber: "88776630",
//            serviceCode: "INT_TOP_UP",
//            iPayCustomerID: "13"
//        )
//        .previewLayout(.sizeThatFits)
//    }
//}
