import SwiftUI
import Combine
import ContactsUI
import UIKit

public struct VouchersView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: VouchersViewModel
    
    @State private var showDeletionModal = false
    @State private var deletionMessage = ""
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var tab: VouchersTabView.Tab = .new
    
    @State private var search = ""
    
    @State private var saveRecharge = true
    
    @State private var country: CountryItem?
    @State private var showPicker = false
    
    @State private var selectedProvider: ProviderItem?
    
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
        self.vm = VouchersViewModel(
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
    
    private var filteredProviders: [ProviderItem] {
        if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return vm.providers
        } else {
            return vm.providers.filter {
                $0.name.localizedCaseInsensitiveContains(search)
            }
        }
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
                        Text("Step 1 of 4")
                            .font(.custom("VodafoneRg-Regular", size: 16))
                            .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Text("Select Gift Voucher")
                            .font(.custom("VodafoneRg-Bold", size: 20))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 75)
                    
                    // Tabs
                    VouchersTabView(selection: $tab)
                    
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                CountryPicker(
                    vm: vm
                ) { selectedCountry in
                    country = selectedCountry
                    
                    Task {
                        await vm.loadProviders(for: selectedCountry.countryIso)
                    }
                }
            }
            .onAppear {
                Task {
                    await vm.loadCountries()
                    if let qaCountry = vm.countries.first(where: { $0.countryIso == "QA" }) {
                        country = qaCountry
                        await vm.loadProviders(for: qaCountry.countryIso)
                    }
                }
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
        // }
    }
    
    // MARK: – New Top-Up Tab
    private var newTopUpView: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                
                HStack(spacing: 16) {
                    // ─── Search Field ────────────────────────────────────────────
                    HStack(spacing: 8) {
                        Image("ic_search", bundle: .module)
                            .frame(width: 16, height: 16)
                            .scaledToFit()
                        
                        TextField("Search", text: $search, onEditingChanged: { _ in
                        })
                        .font(.custom("VodafoneRg-Regular", size: 16.0))
                        .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color("keyBs_white", bundle: .module))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("keyBs_bg_gray_1", bundle: .module), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Country Field
                    Button {
                        showPicker = true
                    } label: {
                        HStack(spacing: 8) {
                            if let c = country {
                                SVGImageView(url: c.flagUrl)
                                    .frame(width: 24, height: 24)
                                    .scaledToFit()
                                    .cornerRadius(24)
                                
                                Text(c.name)
                                    .font(.custom("VodafoneRg-Regular", size: 16.0))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("All Countries")
                                    .font(.custom("VodafoneRg-Regular", size: 16.0))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            // Spacer()
                            
                            Image("ic_chevron_down", bundle: .module)
                                .frame(width: 20, height: 20)
                                .scaledToFit()
                        }
                        .padding(.trailing, 12)
                        // .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 24)
                
                if !vm.providers.isEmpty {
                    // ProvidersGridView(providers: vm.providers)
                    // ProvidersGridView(providers: filteredProviders)
                    ProvidersGridView(
                        providers: filteredProviders,
                        onSelect: { provider in
                            selectedProvider = provider
                            showProducts = true
                        }
                    )
                } else {
                    Spacer()
                    Text("No providers found")
                        .font(.custom("VodafoneRg-Regular", size: 18))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(50, corners: [.topLeft])
            .edgesIgnoringSafeArea(.all)
            
            NavigationLink(
                destination: Group {
                    if let provider = selectedProvider, let c = country {
                        SelectAmountView(
                            saveRecharge: saveRecharge ? "1" : "0",
                            receiverMobileNumber: vm.mobileNumber,
                            countryIso: c.countryIso,
                            countryFlagUrl: c.flagUrl,
                            countryName: c.name,
                            providerCode: provider.providerCode,
                            providerLogoUrl: provider.logoUrl,
                            providerName: provider.name,
                            productSku: "",
                            mobileNumber: vm.mobileNumber,
                            serviceCode: vm.serviceCode,
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
        }
        .background(Color("keyBs_bg_red_tabs", bundle: .module))
    }
    
    // MARK: - Providers Grid
    private struct ProvidersGridView: View {
        let providers: [ProviderItem]
        let onSelect: (ProviderItem) -> Void
        let columns = 2
        let spacing: CGFloat = 20
        
        var rows: [[ProviderItem]] {
            stride(from: 0, to: providers.count, by: columns).map {
                Array(providers[$0..<min($0 + columns, providers.count)])
            }
        }
        
        var body: some View {
            GeometryReader { geometry in
                let totalSpacing = CGFloat(columns - 1) * spacing
                let cardWidth = (geometry.size.width - totalSpacing - 32) / CGFloat(columns)
                ScrollView {
                    //                    VStack(alignment: .leading, spacing: spacing) {
                    VStack(alignment: .leading) {
                        ForEach(0..<rows.count, id: \.self) { rowIndex in
                            HStack(spacing: spacing) {
                                ForEach(rows[rowIndex], id: \.id) { provider in
                                    ProviderCard(provider: provider, cardWidth: cardWidth)
                                        .onTapGesture {
                                            onSelect(provider)
                                        }
                                }
                                // Fill empty columns for last row if needed
                                if rows[rowIndex].count < columns {
                                    ForEach(0..<(columns - rows[rowIndex].count), id: \.self) { _ in
                                        Spacer()
                                            .frame(width: cardWidth)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
            }
        }
    }
    
    // MARK: - Provider Card
    private struct ProviderCard: View {
        let provider: ProviderItem
        let cardWidth: CGFloat
        
        var body: some View {
            VStack(spacing: 0) {
                RemoteImage(
                    url: provider.logoUrl,
                    placeholder: AnyView(Color.gray.opacity(0.3))
                )
                .aspectRatio(contentMode: .fit) // maintain aspect ratio
                .frame(minHeight: cardWidth * 0.6) // 60% of card height for image
                //.frame(height: cardWidth * 0.6) // 60% of card height for image
                .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .topRight]))
                
                Text(provider.name)
                    .font(.custom("VodafoneRg-Regular", size: 16))
                    .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
//                    .frame(height: cardWidth * 0.3)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        Color("keyBs_bg_gray_1", bundle: .module),
                        lineWidth: 1
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("keyBs_bg_gray_3", bundle: .module))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.bottom, 24)
            //            .frame(width: cardWidth, height: cardWidth * 1.2) // Square card, or change height as needed
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
                                        
                                        let (textPin, valuePin) = extractPinParams(from: c.reciptParams)

                                        
                                        ViewVoucherView(
                                            close: false,
                                            
                                            displayText: c.productDisplayText,
                                            
                                            countryFlagUrl: c.countryFlagUrl,
                                            countryName: c.countryName,
                                            providerName: c.providerName,
                                            providerLogoUrl: c.providerImgUrl,
                                            dateTime: c.dateTime,
                                            refId: c.billingRef ?? "",
                                            
                                            descriptionMarkdown: c.descriptionMarkdown ?? "",
                                            readMoreMarkdown: c.readMoreMarkdown ?? "",
                                            
                                            textPin: textPin,
                                            valuePin: valuePin
                                        )
                                        .environmentObject(coord)
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
    
    private func extractPinParams(from receiptParams: String?) -> (textPin: String, valuePin: String) {
        guard
            let receiptParamsString = receiptParams,
            let data = receiptParamsString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let (key, value) = json.first
        else {
            return ("", "")
        }
        return ("\(key)", "\(value)")
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
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        withAnimation {
//                            offsetX = 0
//                            isOpen = false
//                        }
//                        onDelete()
//                    }) {
//                        Image("ic_delete", bundle: .module)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24, height: 24)
//                            .padding()
//                            .background(Color("keyBs_bg_gray_4", bundle: .module))
//                            .cornerRadius(12)
//                    }
//                    .frame(width: deleteWidth, height: 60)
//                    .padding(.trailing, 16)
//                }
                
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
                            RemoteImage(
                                url: bill.providerImgUrl,
                                placeholder: AnyView(Color.gray.opacity(0.3)),
                                isResizable: true
                            )
                          //  .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit) // maintain aspect ratio
                          //  .scaledToFit()
                            .padding(10)


                        }
                        .frame(width: 48, height: 48)
                        .background(Color("keyBs_bg_gray_4", bundle: .module))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bill.productDisplayText)
                                .font(.custom("VodafoneRg-Bold", size: 16))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                            
                            Text(bill.dateTime)
                                .font(.custom("VodafoneRg-Regular", size: 14))
                                .foregroundColor(Color("keyBs_font_gray_3", bundle: .module))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Text("\(bill.currency) \(bill.amount)")
                            .font(.custom("VodafoneRg-Bold", size: 18))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                                
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 31)
                    .background(Color.white)
                }
                .buttonStyle(.plain)
//                .offset(x: offsetX)
//                .highPriorityGesture(
//                    DragGesture()
//                        .onChanged { value in
//                            // Only allow left swipe, clamp to -deleteWidth
//                            if value.translation.width < 0 {
//                                offsetX = max(value.translation.width, -deleteWidth)
//                            }
//                        }
//                        .onEnded { value in
//                            withAnimation {
//                                if value.translation.width < -deleteWidth / 2 {
//                                    offsetX = -deleteWidth
//                                    isOpen = true
//                                } else {
//                                    offsetX = 0
//                                    isOpen = false
//                                }
//                            }
//                        }
//                    
//                )
//                .animation(.easeOut(duration: 0.2), value: offsetX)
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
