import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

public struct SelectAmountView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    @ObservedObject private var vm: SelectAmountViewModel
    
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
        self.vm = SelectAmountViewModel(
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
    
    internal init(vm: SelectAmountViewModel) {
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
                
                
                
                ScrollView {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step 2 of 4")
                            .font(.custom("VodafoneRg-Regular", size: 16))
                            .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Text("Select Amount")
                            .font(.custom("VodafoneRg-Bold", size: 20))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 32)
                    
                    amountSelectionSection
                    
                    //                    Spacer()
                    
                    
                }
                // .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                Spacer().frame(height: 16)
                
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
                NavigationLink(
                    destination: Group {
                        if let p = vm.selectedProduct {
                            ReviewVoucherView(
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
        //.contentShape(Rectangle())
        //.onTapGesture {
        //    UIApplication.shared.endEditing()
        //}
       // .sdkDismissKeyboardOnTap() 
    }
    
    private var amountSelectionSection: some View {
        
        VStack(spacing: 24) {
       
            // Card with image, provider, country
            VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        
                        ZStack {
                            Color.white // ensures white bg even if logo has transparency
                            RemoteImage(
                                url: vm.providerLogoUrl,
                                placeholder: AnyView(Color.gray.opacity(0.3)),
                                isResizable: true
                            )
                            .scaledToFit()               // keep logo aspect
                            //.padding(logoInset)          // breathing room inside well
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.4,
                                   alignment: .leading
                            )  // center horizontally

                        }
                        .aspectRatio(contentMode: .fit) // size from width; no hard height
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.4, alignment: .leading) // 60% of card height for image
                        .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                        Spacer()
                        
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                
                HStack(spacing: 8) {
                    Text(vm.providerName)
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    //                    Spacer()
                    
                    SVGImageView(url: vm.countryFlagUrl)
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                        .cornerRadius(20)
                    
                    Text(vm.countryName)
                        .font(.custom("VodafoneRg-Regular", size: 18))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color("keyBs_bg_gray_3", bundle: .module))
            }
            .background(Color("keyBs_bg_gray_4", bundle: .module))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            
            // Select amount
            VStack(alignment: .leading, spacing: 16) {
                Text("Please select")
                    .font(.custom("VodafoneRg-Bold", size: 16))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.products, id: \.skuCode) { product in
                            Button(action: {
                                vm.selectedProduct = product
                            }) {
                                VStack {
                                    Text(product.displayText)
                                        .font(.custom(
                                            vm.selectedProduct?.skuCode == product.skuCode ? "VodafoneRg-Bold" : "VodafoneRg-Regular",
                                            size: 13
                                        ))
                                        .foregroundColor(
                                            vm.selectedProduct?.skuCode == product.skuCode
                                            ? Color("keyBs_white", bundle: .module)
                                            : Color("keyBs_font_gray_2", bundle: .module)
                                        )
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true) // allow wrapping but avoid forced width
                                        .frame(maxWidth: 100) // only limits width for long text

                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .background(
                                    vm.selectedProduct?.skuCode == product.skuCode
                                    ? Color("keyBs_bg_red_1", bundle: .module)
                                    : Color("keyBs_bg_gray_6", bundle: .module)
                                )
                                .cornerRadius(40)
                            }
                        }
                    }
                }
                

            }
            .padding(.horizontal, 16)
            
            
            // Key Information
            let infoArr: [String] = {
                var arr: [String] = []
                if let desc = vm.selectedProduct?.descriptionMarkdown, !desc.isEmpty {
                    arr.append(desc)
                }
                if let readMore = vm.selectedProduct?.readMoreMarkdown, !readMore.isEmpty {
                    arr.append(readMore)
                }
                return arr
            }()
            if !infoArr.isEmpty {
                AccordionView(
                    title: "Key Information",
                    content: {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(infoArr, id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 6, height: 6)
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .padding(.top, 6)
                                    
                                    Text(item)
                                        .font(.custom("VodafoneRg-Regular", size: 16))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            
            
        }
    }
    
    struct AccordionView<Content: View>: View {
        let title: String
        @ViewBuilder let content: Content
        @State private var expanded = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: { withAnimation { expanded.toggle() } }) {
                    HStack {
                        Text(title)
                            .font(.custom("VodafoneRg-Bold", size: 14))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .frame(width: 16, height: 16)
                    }
                    .padding(.all, 16)
                }
                
                if expanded {
                    content
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 16)
                }
                
            }
            .background(Color("keyBs_bg_gray_7", bundle: .module))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    
    // Place this at file scope (not inside any struct/class)
    private struct SizePreferenceKey: PreferenceKey {
        static var defaultValue: [AnyHashable: CGSize] = [:]
        static func reduce(value: inout [AnyHashable: CGSize], nextValue: () -> [AnyHashable: CGSize]) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }
    
    // FlexibleView that wraps items to new lines as needed
    struct FlexibleView<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
        let data: Data
        let id: KeyPath<Data.Element, ID>
        let spacing: CGFloat
        let alignment: HorizontalAlignment
        let content: (Data.Element) -> Content
        
        @State private var sizes: [AnyHashable: CGSize] = [:]
        
        init(
            data: Data,
            id: KeyPath<Data.Element, ID>,
            spacing: CGFloat = 8,
            alignment: HorizontalAlignment = .leading,
            @ViewBuilder content: @escaping (Data.Element) -> Content
        ) {
            self.data = data
            self.id = id
            self.spacing = spacing
            self.alignment = alignment
            self.content = content
        }
        
        var body: some View {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        
        private func generateContent(in geometry: GeometryProxy) -> some View {
            var rows: [[Data.Element]] = [[]]
            var currentRowWidth: CGFloat = 0
            
            for item in data {
                let itemID = AnyHashable(item[keyPath: id])
                let itemSize = sizes[itemID, default: CGSize(width: 100, height: 40)]
                if currentRowWidth + itemSize.width + (rows[rows.count - 1].isEmpty ? 0 : spacing) > geometry.size.width {
                    rows.append([item])
                    currentRowWidth = itemSize.width
                } else {
                    rows[rows.count - 1].append(item)
                    currentRowWidth += itemSize.width + (rows[rows.count - 1].count > 1 ? spacing : 0)
                }
            }
            
            return VStack(alignment: alignment, spacing: spacing) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rows[rowIndex], id: id) { item in
                            content(item)
                                .fixedSize()
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: SizePreferenceKey.self, value: [AnyHashable(item[keyPath: id]): geo.size])
                                    }
                                )
                        }
                    }
                }
            }
            .onPreferenceChange(SizePreferenceKey.self) { value in
                self.sizes.merge(value) { $1 }
            }
        }
    }
    
}
