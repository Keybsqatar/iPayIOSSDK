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
                                coord.closeSDK()
                            default:
                                presentationMode.wrappedValue.dismiss()
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
                    
                    Text("Select Amount")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                ScrollView {
                    amountSelectionSection
                }
                // .frame(maxWidth: .infinity, maxHeight: .infinity)
                
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
                            .navigationBarHidden(true)
                        }
                    },
                    isActive: $showReview,
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
    
    private var amountSelectionSection: some View {
        VStack(spacing: 24) {
            // Card with image, provider, country
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    RemoteImage(
                        url: vm.providerLogoUrl,
                        placeholder: AnyView(Color.gray.opacity(0.3))
                    )
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.vertical, 32)
                    .padding(.horizontal, 50)
                }
                
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
            
            // Description
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .padding(.top, 6)
                    
                    Text("Give this code to a friend or loved one to be redeemed at \(vm.providerName).")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .padding(.top, 6)
                    
                    Text("The code will be saved under Gift Cards section to be copied or shared")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color("keyBs_bg_gray_7", bundle: .module))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Please select a voucher amount")
                    .font(.custom("VodafoneRg-Bold", size: 16))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.products, id: \.skuCode) { product in
                            Button(action: {
                                vm.selectedProduct = product
                            }) {
                                Text("$ \(product.displayText.filter { $0.isNumber })")
                                    .font(.custom(vm.selectedProduct?.skuCode == product.skuCode ? "VodafoneRg-Bold" : "VodafoneRg-Regular", size: 12))
                                    .foregroundColor(vm.selectedProduct?.skuCode == product.skuCode ? Color("keyBs_white", bundle: .module) : Color("keyBs_font_gray_2", bundle: .module))
                                    .padding(.vertical, 9)
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
            
            //             VStack(alignment: .leading, spacing: 16) {
            //                 Text("Please select a voucher amount")
            //                     .font(.custom("VodafoneRg-Bold", size: 18))
            //                     .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
            
            //                 // Set how many buttons per row you want
            //                 let itemsPerRow = 3
            // let rows = vm.products.chunked(into: itemsPerRow)
            // ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
            //     HStack(spacing: 16) {
            //         ForEach(row, id: \.skuCode) { product in
            //             Button(action: {
            //                 vm.selectedProduct = product
            //             }) {
            //                 Text(product.displayText)
            //                     .font(.custom("VodafoneRg-Bold", size: 16))
            //                     .foregroundColor(vm.selectedProduct?.skuCode == product.skuCode ? .white : Color("keyBs_font_gray_2", bundle: .module))
            //                     .padding(.vertical, 8)
            //                     .padding(.horizontal, 28)
            //                     .background(
            //                         vm.selectedProduct?.skuCode == product.skuCode
            //                         ? Color("keyBs_bg_red_1", bundle: .module)
            //                         : Color("keyBs_bg_gray_1", bundle: .module)
            //                     )
            //                     .cornerRadius(24)
            //             }
            //         }
            //         Spacer()
            //     }
            // }
            //             }
            //             .padding(.horizontal, 16)
            //             .padding(.bottom, 16)
            
            
            // Select amount
            // VStack(alignment: .leading, spacing: 16) {
            //     Text("Please select a voucher amount")
            //         .font(.custom("VodafoneRg-Bold", size: 18))
            //         .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
            
            //     FlexibleView(
            //         data: vm.products,
            //         id: \.skuCode,
            //         spacing: 16,
            //         alignment: .leading
            //     ) { product in
            //         Button(action: {
            //             vm.selectedProduct = product
            //         }) {
            //             Text(product.displayText)
            //                 .font(.custom("VodafoneRg-Bold", size: 16))
            //                 .foregroundColor(vm.selectedProduct?.skuCode == product.skuCode ? .white : Color("keyBs_font_gray_2", bundle: .module))
            //                 .padding(.vertical, 8)
            //                 .padding(.horizontal, 28)
            //                 .background(
            //                     vm.selectedProduct?.skuCode == product.skuCode
            //                     ? Color("keyBs_bg_red_1", bundle: .module)
            //                     : Color("keyBs_bg_gray_1", bundle: .module)
            //                 )
            //                 .cornerRadius(24)
            //         }
            //     }
            //     .fixedSize(horizontal: false, vertical: true) // Important for iOS 13
            // }
            // .padding(.horizontal, 16)
            // .padding(.bottom, 16)
            
            // Important box
            VStack(alignment: .leading, spacing: 20) {
                Text("Important :")
                    .font(.custom("VodafoneRg-Bold", size: 14))
                    .foregroundColor(Color("keyBs_bg_red_1", bundle: .module))
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .padding(.top, 6)
                    
                    Text("This code is only going to be valid on \(vm.providerName) and is not valid on other Amazon sites")
                        .font(.custom("VodafoneRg-Regular", size: 14))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .padding(.top, 6)
                    
                    Text("This voucher will cost \(vm.selectedProduct?.sendCurrencyIso ?? "") \(vm.selectedProduct?.sendValue ?? "")")
                        .font(.custom("VodafoneRg-Regular", size: 14))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            .background(Color("keyBs_bg_pink_1", bundle: .module))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .padding(.horizontal, 16)
            
//            AccordionView(
//                title: "Additional T&C’s",
//                content: {
//                    VStack(alignment: .leading, spacing: 8) {
//                        ForEach([
//                            "Lorem ipsum dolor sit amet consectetur",
//                            "Nulla et tincidunt dui bibendum purus ullamcorper sit sit",
//                            "Curabitur quisque nascetur ac mollis suspendisse morbi",
//                            "Ipsum rutrum interdum semper mattis",
//                            "In odio felis lectus enim molestie."
//                        ], id: \.self) { item in
//                            HStack(alignment: .top, spacing: 8) {
//                                Image(systemName: "circle.fill")
//                                    .resizable()
//                                    .frame(width: 6, height: 6)
//                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
//                                    .padding(.top, 6)
//                                
//                                Text(item)
//                                    .font(.custom("VodafoneRg-Regular", size: 16))
//                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
//                                    .multilineTextAlignment(.leading)
//                            }
//                        }
//                    }
//                }
//            )
//            .padding(.horizontal, 16)
            
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
//
//#Preview {
//    ProductsView(
//        saveRecharge: "0",
//        receiverMobileNumber: "45456456",
//        countryIso: "AE",
//        countryFlagUrl: URL(string: "http://keybs.ai/fg/ae.svg")!,
//        countryName: "United Arab Emirates",
//        providerCode: "E6AE",
//        providerLogoUrl: URL(string: "https://imagerepo.ding.com/logo/DU/AE.png")!,
//        providerName: "DU UAE",
//        productSku: "",
//        
//        mobileNumber: "88776630",
//        serviceCode: "INT_TOP_UP",
//        iPayCustomerID: "13",
//        
//        dismissMode: "pop"
//    )
//}
//
//struct SelectAmountView_PreviewsData: PreviewProvider {
//    static var previews: some View {
//        // Mock ProductsViewModel with sample products
//        let mockProducts = [
//            ProductItem(skuCode: "E6AEAE12938", providerCode: "E6AE", countryIso: "AE", displayText: "AED 20.00", sendValue: "28", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE17155", providerCode: "E6AE", countryIso: "AE", displayText: "AED 50.00", sendValue: "69.6", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE17343", providerCode: "E6AE", countryIso: "AE", displayText: "AED 25.00", sendValue: "34.8", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE17361", providerCode: "E6AE", countryIso: "AE", displayText: "AED 5.00", sendValue: "7", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE22430", providerCode: "E6AE", countryIso: "AE", displayText: "AED 10.00", sendValue: "14.1", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE25659", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 25 (400MB Data)", sendValue: "34.8", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE33503", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 210 (8 GB Data)", sendValue: "292.4", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE35243", providerCode: "E6AE", countryIso: "AE", displayText: "AED 45.00", sendValue: "62.8", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE35435", providerCode: "E6AE", countryIso: "AE", displayText: "AED 300.00", sendValue: "416.7", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE46146", providerCode: "E6AE", countryIso: "AE", displayText: "AED 30.00", sendValue: "41.9", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE46729", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 525 (40 GB Data)", sendValue: "731.1", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE53289", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 110 (2.2 GB Data)", sendValue: "153.3", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE64011", providerCode: "E6AE", countryIso: "AE", displayText: "AED 40.00", sendValue: "55.7", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE73090", providerCode: "E6AE", countryIso: "AE", displayText: "AED 200.00", sendValue: "278.5", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE73954", providerCode: "E6AE", countryIso: "AE", displayText: "AED 35.00", sendValue: "48.9", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE81767", providerCode: "E6AE", countryIso: "AE", displayText: "Data Bundle 55 (1GB Data)", sendValue: "76.7", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE8527", providerCode: "E6AE", countryIso: "AE", displayText: "AED 15.00", sendValue: "20.9", sendCurrencyIso: "QR"),
//            ProductItem(skuCode: "E6AEAE94772", providerCode: "E6AE", countryIso: "AE", displayText: "AED 100.00", sendValue: "139.3", sendCurrencyIso: "QR")
//        ]
//        
//        let vm = SelectAmountViewModel(
//            saveRecharge: "0",
//            receiverMobileNumber: "45456456",
//            countryIso: "AE",
//            countryFlagUrl: URL(string: "http://keybs.ai/fg/ae.svg")!,
//            countryName: "United Arab Emirates",
//            providerCode: "E6AE",
//            providerLogoUrl: URL(string: "https://imagerepo.ding.com/logo/DU/AE.png")!,
//            providerName: "DU UAE",
//            productSku: "",
//            
//            mobileNumber: "88776630",
//            serviceCode: "INT_TOP_UP",
//            iPayCustomerID: "13",
//            
//            dismissMode: "pop"
//        )
//        vm.products = mockProducts
//        
//        return SelectAmountView(vm: vm)
//            .previewLayout(.sizeThatFits)
//    }
//}
