import SwiftUI

public struct ReviewTopUpView: View {
    @Environment(\.presentationMode) private var presentationMode
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
                
                VStack(spacing: 24) {
                    // Summary card
                    ZStack {
                        VStack(spacing: 40) {
                            // Top Card
                            VStack(spacing: 4) {
                                Text("You’ll Pay")
                                    .font(.custom("VodafoneRg-Regular", size: 16))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                HStack(spacing: 8) {
                                    Image("flag_qa", bundle: .module)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .clipShape(Circle())
                                    
                                    Text("\(product.sendCurrencyIso) \(product.sendValue)")
                                        .font(.custom("VodafoneRg-Bold", size: 24))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 28)
                            .frame(maxWidth: .infinity)
                            .background(Color("keyBs_bg_pink_1", bundle: .module))
                            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight]))
                            
                            // Bottom Card
                            VStack(spacing: 4) {
                                Text("You’ll Get")
                                    .font(.custom("VodafoneRg-Regular", size: 16))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                HStack(spacing: 8) {
                                    SVGImageView(url: countryFlagUrl)
                                        .frame(width: 20, height: 20)
                                        .clipShape(Circle())
                                    
                                    Text(product.displayText)
                                        .font(.custom("VodafoneRg-Bold", size: 24))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
//                                        .lineLimit(nil)
//                                        .fixedSize(horizontal: false, vertical: true)
//                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                            }
                            .padding(.top, 28)
                            .padding(.bottom, 20)
//                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color("keyBs_bg_pink_1", bundle: .module))
                            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight]))
                        }
                        .overlay(
                            // "=" Circle Overlay
                            ZStack {
                                Circle()
                                    .fill(Color("keyBs_white", bundle: .module))
                                    .frame(width: 80, height: 80)
                                Text("=")
                                    .font(.custom("VodafoneRg-Bold", size: 24))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .frame(width: 60, height: 60)
                                    .background(Color("keyBs_bg_pink_1", bundle: .module))
                                    .clipShape(Circle())
                            }
                            .offset(y: 0), // Centered by default
                            alignment: .center
                        )
                    }
                    // ...existing code...
                    
                    // HStack {
                    //     VStack(alignment: .leading, spacing: 4) {
                    //         Text("You’ll Pay")
                    //             .font(.custom("VodafoneRg-Regular", size: 16))
                    //             .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    //             .multilineTextAlignment(.leading)
                    //             .frame(maxWidth: .infinity, alignment: .leading)
                    
                    //         HStack(spacing: 4) {
                    //             Image("flag_qa", bundle: .module)
                    //                 .resizable()
                    //                 .frame(width: 16, height: 16)
                    //                 .cornerRadius(16)
                    
                    //             Text("\(product.sendCurrencyIso) \(product.sendValue)")
                    //                 .font(.custom("VodafoneRg-Bold", size: 24))
                    //                 .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    //                 .multilineTextAlignment(.leading)
                    //         }
                    //         .frame(maxWidth: .infinity, alignment: .leading)
                    //     }
                    
                    //     Text("=")
                    //         .font(.custom("VodafoneRg-Bold", size: 24))
                    //         .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    //         .multilineTextAlignment(.leading)
                    
                    //     VStack(alignment: .trailing, spacing: 4) {
                    //         Text("You’ll Get")
                    //             .font(.custom("VodafoneRg-Regular", size: 16))
                    //             .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    //             .multilineTextAlignment(.leading)
                    //             .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    //         HStack {
                    //             SVGImageView(url: countryFlagUrl)
                    //                 .frame(width: 16, height: 16)
                    //                 .scaledToFit()
                    //                 .cornerRadius(16)
                    
                    //             Text("\(product.displayText)")
                    //                 .font(.custom("VodafoneRg-Bold", size: 24))
                    //                 .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    //                 .multilineTextAlignment(.leading)
                    //         }
                    //         .frame(maxWidth: .infinity, alignment: .trailing)
                    //     }
                    // }
                    // .padding(.all, 16)
                    // .background(Color("keyBs_bg_pink_1", bundle: .module))
                    // .cornerRadius(8)
                    
                    // Details card
                    VStack(spacing: 12) {
                        detailRow(label: "Country",      value: countryName,        svgIconURL: countryFlagUrl)
                        detailRow(label: "Mobile",value: receiverMobileNumber)
                        detailRow(label: "Operator",value: providerName,       logoIconURL: providerLogoUrl)
                    }
                    .padding(.all, 16)
                    .background(
                        Color("keyBs_white_2", bundle: .module)
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                Color("keyBs_bg_gray_1", bundle: .module),
                                lineWidth: 1
                            )
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
                            billAmount: "0",
                            
                            receiverMobileNumber: receiverMobileNumber,
                            settingsData: "",
                            
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
       // .onTapGesture {
       //     UIApplication.shared.endEditing()
       // }
       // .sdkDismissKeyboardOnTap() 
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
