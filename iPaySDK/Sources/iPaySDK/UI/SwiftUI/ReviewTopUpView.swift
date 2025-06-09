import SwiftUI

public struct ReviewTopUpView: View {
    @Environment(\.dismiss) private var pop
    @EnvironmentObject private var coord: SDKCoordinator
    
    // MARK: – Inputs
    public let saveRecharge:         String
    public let receiverMobileNumber: String
    public let countryIso:           String
    public let countryName:          String
    public let countryFlagUrl:       URL
    public let providerCode:         String
    public let providerName:         String
    public let providerLogoUrl:      URL
    public let mobileNumber:         String
    public let serviceCode:          String
    public let iPayCustomerID:       String
    public let product:              ProductItem
    
    @State private var disabledProceed = false
    @State private var showOtp = false
    
    public init(
        saveRecharge:         String,
        receiverMobileNumber:  String,
        countryIso:            String,
        countryFlagUrl:        URL,
        countryName:           String,
        providerCode:          String,
        providerLogoUrl:       URL,
        providerName:          String,
        product:               ProductItem,
        
        mobileNumber:          String,
        serviceCode:           String,
        iPayCustomerID:        String
    ) {
        self.saveRecharge         = saveRecharge
        self.receiverMobileNumber  = receiverMobileNumber
        self.countryIso            = countryIso
        self.countryFlagUrl        = countryFlagUrl
        self.countryName           = countryName
        self.providerCode          = providerCode
        self.providerLogoUrl       = providerLogoUrl
        self.providerName          = providerName
        self.mobileNumber          = mobileNumber
        self.serviceCode           = serviceCode
        self.iPayCustomerID        = iPayCustomerID
        self.product               = product
    }
    
    public var body: some View {
        ZStack(alignment: .bottom){
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
                    Text("Step 3 of 4")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Text("Review Topup Details")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                VStack(spacing: 32) {
                    // Summary card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("You’ll Pay")
                                .font(.custom("VodafoneRg-Regular", size: 16))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 4) {
                                Image("flag_qa", bundle: .module)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .cornerRadius(16)
                                
                                Text("\(product.sendCurrencyIso) \(product.sendValue)")
                                    .font(.custom("VodafoneRg-Bold", size: 24))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text("=")
                            .font(.custom("VodafoneRg-Bold", size: 24))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("You’ll Get")
                                .font(.custom("VodafoneRg-Regular", size: 16))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            HStack {
                                SVGImageView(url: countryFlagUrl)
                                    .frame(width: 16, height: 16)
                                    .scaledToFit()
                                    .cornerRadius(16)
                                
                                Text("\(product.displayText)")
                                    .font(.custom("VodafoneRg-Bold", size: 24))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.all, 16)
                    .background(Color("keyBs_bg_pink_1", bundle: .module))
                    .cornerRadius(8)
                    
                    // Details card
                    VStack(spacing: 12) {
                        detailRow(label: "Country",      value: countryName,        svgIconURL: countryFlagUrl)
                        detailRow(label: "Mobile Number",value: receiverMobileNumber)
                        detailRow(label: "Operator Name",value: providerName,       logoIconURL: providerLogoUrl)
                    }
                    .padding(.all, 16)
                    .background(
                        Color("keyBs_white_2", bundle: .module)
                    )
                    // 2) rounded corners
                    .cornerRadius(8)
                    // 3) border
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                Color("keyBs_bg_gray_1", bundle: .module),
                                lineWidth: 1
                            )
                    )
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color( "keyBs_white_2", bundle: .module))
//                            .stroke(
//                                Color( "keyBs_bg_gray_1", bundle: .module),
//                                lineWidth: 1
//                            )
//                    )
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: { showOtp = true }) {
                    Text("Proceed for Payment")
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
                .navigationDestination(isPresented: $showOtp) {
                    OtpView(
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
                    .toolbar(.hidden, for: .navigationBar)
                }
                
                // // Proceed Button
                // Button("Proceed for Payment") {
                //     showOtp = true
                // }
                // .navigationDestination(isPresented: $showOtp) {
                //     OtpView(
                //         saveRecharge: saveRecharge,
                //         receiverMobileNumber: receiverMobileNumber,
                //         countryIso: countryIso,
                //         countryFlagUrl: countryFlagUrl,
                //         countryName: countryName,
                //         providerCode: providerCode,
                //         providerLogoUrl: providerLogoUrl,
                //         providerName: providerName,
                //         product: product,
                //         mobileNumber: mobileNumber,
                //         serviceCode: serviceCode,
                //         iPayCustomerID: iPayCustomerID
                //     )
                //     .toolbar(.hidden, for: .navigationBar)
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
            .ignoresSafeArea(edges: .bottom)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    @ViewBuilder
    private func detailRow(
        label: String,
        value: String,
        svgIconURL: URL? = nil,
        logoIconURL: URL? = nil
    )-> some View
    {
        HStack {
            Text(label)
                .font(.custom("VodafoneRg-Regular", size: 16))
                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            HStack(spacing: 8) {
                if let url = svgIconURL {
                    SVGImageView(url: url)
                        .frame(width: 16, height: 16)
                        .scaledToFit()
                        .cornerRadius(16)
                } else if let url = logoIconURL {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFit()
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(width: 16, height: 16)
                }
                
                Text(value)
                    .font(.custom("VodafoneRg-Bold", size: 16))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
            }
            .frame(alignment: .trailing)
            
            
        }
    }
}

#Preview {
    ReviewTopUpView(
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

struct ReviewTopUpView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewTopUpView(
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
