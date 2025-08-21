import SwiftUI
import Combine
import ContactsUI
import UIKit

public struct EnterUtilityDetailsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    // MARK: – Inputs
    public let saveRecharge:         String
    
    public let countryIso:           String
    public let countryName:          String
    public let countryFlagUrl:       URL
    public let countryPrefix: String
    public let countryMinimumLength: Int
    public let countryMaximumLength: Int
    
    public let providerCode:         String
    public let providerName:         String
    public let providerLogoUrl:      URL
    public let providerValidationRegex: String
    
    public let settingDefinitions:           [SettingDefinition]
    
    //    public let product:              ProductItem
    //    public let billAmount:           String
    
    public let mobileNumber:         String
    public let serviceCode:          String
    public let iPayCustomerID:       String
    
    @State private var dynamicFields: [String: String] = [:]
    
    @State private var accountNoConsumerId = ""
    @State private var phone = ""
    @State private var contactDelegate = ContactDelegate()
    
    @State private var disabledProceed = false
    @State private var showEnterAmount = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
        
    @State private var enterAmountVM: EnterAmountViewModel? = nil
    
    public init(
        saveRecharge:         String,
        
        countryIso:            String,
        countryFlagUrl:        URL,
        countryName:           String,
        countryPrefix: String,
        countryMinimumLength: String,
        countryMaximumLength: String,
        
        providerCode:          String,
        providerLogoUrl:       URL,
        providerName:          String,
        providerValidationRegex: String,
        
        settingDefinitions:          [SettingDefinition],
        //        product:               ProductItem,
        //        billAmount:          String,
        
        mobileNumber:          String,
        serviceCode:           String,
        iPayCustomerID:        String
    ) {
        self.saveRecharge         = saveRecharge
        
        self.countryIso            = countryIso
        self.countryFlagUrl        = countryFlagUrl
        self.countryName           = countryName
        self.countryPrefix         = countryPrefix
        self.countryMinimumLength  = (Int(countryMinimumLength) ?? 0) - countryPrefix.count
        self.countryMaximumLength  = (Int(countryMaximumLength) ?? 0) - countryPrefix.count
        
        self.providerCode          = providerCode
        self.providerLogoUrl       = providerLogoUrl
        self.providerName          = providerName
        self.providerValidationRegex = providerValidationRegex
        
        self.settingDefinitions    = settingDefinitions
        //        self.product               = product
        //        self.billAmount            = billAmount
        
        self.mobileNumber          = mobileNumber
        self.serviceCode           = serviceCode
        self.iPayCustomerID        = iPayCustomerID
    }
    
    @State private var otpVM: OtpViewModel? = nil
    
    public var body: some View {
        ZStack(alignment: .bottom){
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
                    Text("Step 2 of 5")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Text("Enter Utility Details")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                VStack(spacing: 30) {
                    
                    // ─── Dynamic Fields ──────────────────────────────────────────────
                    //                    ForEach(product.settingDefinitions, id: \.Name) { setting in
                    ForEach(settingDefinitions, id: \.Name) { setting in
                        VStack(spacing: 8) {
                            if let value = dynamicFields[setting.Name], !value.isEmpty {
                                Text(setting.Description)
                                    .font(.custom("VodafoneRg-Regular", size: 16.0))
                                    .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            HStack {
                                TextField(
                                    "",
                                    text: Binding(
                                        get: { dynamicFields[setting.Name] ?? "" },
                                        set: { dynamicFields[setting.Name] = $0 }
                                    )
                                )
                                .font(.custom("VodafoneRg-Bold", size: 16.0))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .placeholder(when: (dynamicFields[setting.Name] ?? "").isEmpty) {
                                    Text(setting.Description)
                                        .font(.custom("VodafoneRg-Regular", size: 16.0))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .multilineTextAlignment(.leading)
                                }
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity)
                                .onReceive(Just(dynamicFields[setting.Name] ?? "")) { _ in
                                    //                                    let allFieldsFilled = product.settingDefinitions.allSatisfy {
                                    let allFieldsFilled = settingDefinitions.allSatisfy {
                                        setting in
                                        !(dynamicFields[setting.Name] ?? "").isEmpty
                                    }
                                    if allFieldsFilled && phone.count >= countryMinimumLength {
                                        disabledProceed = false
                                    } else {
                                        disabledProceed = true
                                    }
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
                                    //                                    let allFieldsFilled = product.settingDefinitions.allSatisfy {
                                    let allFieldsFilled = settingDefinitions.allSatisfy {
                                        setting in
                                        !(dynamicFields[setting.Name] ?? "").isEmpty
                                    }
                                    if allFieldsFilled && newValue.count >= countryMinimumLength {
                                        disabledProceed = false
                                    } else {
                                        disabledProceed = true
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
                
                Spacer()
                
                Button(action: {
                    if (phone.count < countryMinimumLength) || (phone.count > countryMaximumLength) {
                        toastMessage = "Mobile number must be between \(countryMinimumLength) and \(countryMaximumLength) digits."
                        showToast = true
                        return
                    }
                    
                   /* let regexPattern = selectedProvider?.validationRegex ?? ""
                    let fullReceiverMobileNumber = (country?.prefix ?? "") + phone
                    
                    if !regexPattern.isEmpty {
                        if fullReceiverMobileNumber.range(of: regexPattern, options: .regularExpression) == nil {
                            toastMessage = "Invalid mobile number format for the selected provider."
                            showToast = true
                            return
                        }
                    }*/

                    
                    let regexPattern = providerValidationRegex ?? ""
                    //let fullReceiverMobileNumber = phone//(countryPrefix ?? "") + phone
                    
                    if !regexPattern.isEmpty {
                        if phone.range(of: regexPattern, options: .regularExpression) == nil {
                            let fullReceiverMobileNumber = (countryPrefix ?? "") + phone
                            if fullReceiverMobileNumber.range(of: regexPattern, options: .regularExpression) == nil {
                                toastMessage = "Invalid mobile number format for the selected provider."
                                showToast = true
                                return
                            }
                        }
                    }
                    
                    if otpVM == nil {
                        enterAmountVM = EnterAmountViewModel(
                            saveRecharge: saveRecharge,
                           
                            countryIso:            countryIso,
                            countryFlagUrl:        countryFlagUrl,
                            countryName:           countryName,
                            countryPrefix:         countryPrefix,
                           
                            providerCode:          providerCode,
                            providerLogoUrl:       providerLogoUrl,
                            providerName:          providerName,
                           
                            productSku: "",
                            receiverMobileNumber: phone,
                            settingsData: encodeDynamicFields() ?? "",
                           
                            mobileNumber:          mobileNumber,
                            serviceCode:           serviceCode,
                            iPayCustomerID:        iPayCustomerID,
                           
                            dismissMode: "pop"
                        )
                    }
                    showEnterAmount = true
                }) {
                    Text("Retrieve Bill")
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
                        if let enterAmountVM = enterAmountVM {
                            EnterAmountView(vm: enterAmountVM)
                                .environmentObject(coord)
                                .navigationBarHidden(true)
                        }
                    },
                    isActive: $showEnterAmount,
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
            .edgesIgnoringSafeArea(.bottom)
        }
        .toast(isShowing: $showToast, message: toastMessage)
        .sdkDismissKeyboardOnTap()    // ← add this, and delete the old onTapGesture
        //.contentShape(Rectangle())
        //.onTapGesture {
        //    UIApplication.shared.endEditing()
        //}
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
        var cleanedPhone = selected
        let mobileMaxLength = countryMaximumLength - countryPrefix.count
        if cleanedPhone.count > mobileMaxLength {
            let prefix = countryPrefix
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
        
    }
    
    private func encodeDynamicFields() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dynamicFields, options: []) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}
