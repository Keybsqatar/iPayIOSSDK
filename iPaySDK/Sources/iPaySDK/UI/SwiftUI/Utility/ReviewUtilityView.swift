import SwiftUI

public struct ReviewUtilityView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    // MARK: – Inputs
    public let saveRecharge:         String
        
    public let countryIso:           String
    public let countryFlagUrl:       URL
    public let countryName:          String
    public let countryPrefix:        String
    
    public let providerCode:         String
    public let providerLogoUrl:      URL
    public let providerName:         String
    
    public let product:              ProductItem
    public let billAmount:         String
    
    public let receiverMobileNumber:         String
    public let settingsData:         String
//    public let settingsData:         [String: String]
    
    public let mobileNumber:         String
    public let serviceCode:          String
    public let iPayCustomerID:       String
    
    @State private var disabledProceed = false
    @State private var showOtp = false
    
    public init(
        saveRecharge:         String,
        
        countryIso:            String,
        countryFlagUrl:        URL,
        countryName:           String,
        countryPrefix:        String,
        
        providerCode:          String,
        providerLogoUrl:       URL,
        providerName:          String,
        
        product:               ProductItem,
        billAmount:            String,
        
        receiverMobileNumber:  String,
        settingsData:          String,
//        settingsData:          [String: String],
        
        mobileNumber:          String,
        serviceCode:           String,
        iPayCustomerID:        String
    ) {
        self.saveRecharge         = saveRecharge
        
        self.countryIso            = countryIso
        self.countryFlagUrl        = countryFlagUrl
        self.countryName           = countryName
        self.countryPrefix         = countryPrefix
        
        self.providerCode          = providerCode
        self.providerLogoUrl       = providerLogoUrl
        self.providerName          = providerName

        self.product               = product
        self.billAmount            = billAmount
        
        self.receiverMobileNumber  = receiverMobileNumber
        self.settingsData          = settingsData
        
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
                    Text("Step 4 of 5")
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_1", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Text("Utility Bill Details")
                        .font(.custom("VodafoneRg-Bold", size: 20))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 32)
                
                VStack(spacing: 32) {
                    // Details card
                    VStack(spacing: 24) {
                        detailRow(label: "Country", value: countryName, svgIconURL: countryFlagUrl)
                        detailRow(label: "Company",value: providerName, logoIconURL: providerLogoUrl)
                        DashedDivider()
                        if billAmount != "0" {
                            detailRow(label: "Amount",value: "\(product.sendCurrencyIso) \(billAmount)")
                        }else{
                            detailRow(label: "Amount",value: "\(product.sendCurrencyIso) \(product.sendValue)")
                        }
                        
                        if let data = settingsData.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                            ForEach(product.settingDefinitions, id: \.Name) { setting in
                                let value = json[setting.Name] ?? ""
                                detailRow(
                                    label: setting.Description,
                                    value: value.removingPercentEncoding ?? value
                                )
                            }
                        }
                        detailRow(label: "Mobile Number",value: "\(countryPrefix) \(receiverMobileNumber)")
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 64)
                    .background(
                        ZStack {
                            Image("keybs_bg_receipt_1", bundle: .module)
                                .resizable()
                                .frame(maxWidth: .infinity)
                        }
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: {
                    if otpVM == nil {
                        otpVM = OtpViewModel(
                            saveRecharge: saveRecharge,
                            
                            countryIso: countryIso,
                            countryFlagUrl: countryFlagUrl,
                            countryName: countryName,
                            
                            providerCode: providerCode,
                            providerLogoUrl: providerLogoUrl,
                            providerName: providerName,
                            
                            product: product,
                            billAmount: billAmount,
                            
                            receiverMobileNumber: receiverMobileNumber,
                            settingsData: settingsData,
//                            settingsData: encodeDynamicFields() ?? "",
                            
                            mobileNumber: mobileNumber,
                            serviceCode: serviceCode,
                            iPayCustomerID: iPayCustomerID
                        )
                    }
                    showOtp = true
                }) {
                    Text("Proceed for Payment")
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
                        if let otpVM = otpVM {
                            OtpView(vm: otpVM)
                                .environmentObject(coord)
                                .navigationBarHidden(true)
                        }
                    },
                    isActive: $showOtp,
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
        //.contentShape(Rectangle())
        //.onTapGesture {
        //    UIApplication.shared.endEditing()
        //}
        .sdkDismissKeyboardOnTap() 
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
                    RemoteImage(
                        url: url,
                        placeholder: AnyView(Color.gray.opacity(0.3))
                    )
                    .aspectRatio(contentMode: .fit) // maintain aspect ratio
                    .frame(
                        width: 16,
                        height:16,
                        alignment: .leading
                    )
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
            .foregroundColor(Color("keyBs_bg_gray_1", bundle: .module))
        }
        .frame(height: 1)
    }
}
