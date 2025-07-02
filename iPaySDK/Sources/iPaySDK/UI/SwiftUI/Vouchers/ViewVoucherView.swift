import SwiftUI

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

public struct ViewVoucherView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var coord: SDKCoordinator
    
    // MARK: – Inputs
    public let close:         Bool
    public let displayText:         String
    public let countryFlagUrl:       URL
    public let countryName:          String
    public let providerName:         String
    public let providerLogoUrl:      URL
    public let dateTime:         String
    public let refId:          String
    public let textPin:       String
    public let valuePin:       String
    
    @State private var disabledProceed = false
    @State private var showOtp = false
    @State private var showToast = false
    @State private var showShareSheet = false
    
    public init(
        close:                 Bool = true,
        displayText:         String,
        countryFlagUrl:        URL,
        countryName:           String,
        providerName:          String,
        providerLogoUrl:       URL,
        dateTime:         String,
        refId:          String,
        textPin:       String,
        valuePin:       String
    ) {
        self.close = close
        self.displayText = displayText
        self.countryFlagUrl = countryFlagUrl
        self.countryName = countryName
        self.providerName = providerName
        self.providerLogoUrl = providerLogoUrl
        self.dateTime = dateTime
        self.refId = refId
        self.textPin = textPin
        self.valuePin = valuePin
    }
    
    @State private var otpVM: OtpViewModel? = nil
    
    private var receiptText: String {
        return """
        Receipt Details
        \(textPin): \(valuePin)
        Voucher: \(displayText)
        Country:   \(countryName)
        Purchase Date: \(dateTime)
        Consumer ID: \(refId)
        """
    }
    //        Type:   \(data.type)
    //        Number: \(data.number)
    
    public var body: some View {
        ZStack(alignment: .bottom){
            VStack(spacing: 0) {
                Spacer().frame(height: 32)
                
                // Top Bar
                HStack {
                    Image("ic_back", bundle: .module)
                        .onTapGesture { close ? coord.closeSDK() : presentationMode.wrappedValue.dismiss() }
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
                
                Spacer().frame(height: 45)
                
                // Title
                VStack(alignment: .leading) {
                    Text(displayText)
                        .font(.custom("VodafoneRg-Bold", size: 18))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 40)
                
                VStack(spacing: 32) {
                    // Card with image
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            RemoteImage(
                                url: providerLogoUrl,
                                placeholder: AnyView(Color.gray.opacity(0.3))
                            )
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 87)
                        }
                    }
                    .background(Color("keyBs_bg_gray_7", bundle: .module))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    HStack {
                        Spacer()
                        Text(valuePin)
                            .font(.custom("VodafoneRg-Bold", size: 32))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            UIPasteboard.general.string = refId
                            withAnimation {
                                showToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }) {
                            Image("ic_copy_content", bundle: .module)
                                .frame(width: 24, height: 24)
                                .scaledToFit()
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color("keyBs_bg_pink_1", bundle: .module))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("keyBs_bg_red_1", bundle: .module), style: StrokeStyle(lineWidth: 2, dash: [4]))
                    )
                    .cornerRadius(12)
                    .overlay(
                        Group {
                            if showToast {
                                Text("Copied!")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(16)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .zIndex(1)
                                    .offset(y: -56)
                            }
                        }
                    )
                    
                    // Details card
                    VStack(spacing: 24) {
                        detailRow(label: "Country", value: countryName, svgIconURL: countryFlagUrl)
                        detailRow(label: "Purchase Date",value: dateTime)
                        detailRow(label: "Consumer ID",value: refId)
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
                
                // Share Receipt button
                Button(action: { showShareSheet = true }) {
                    HStack(spacing: 8) {
                        Image("ic_share2", bundle: .module)
                            .frame(width: 24, height: 24)
                            .scaledToFit()
                        
                        Text("Share Receipt")
                            .font(.custom("VodafoneRg-Bold", size: 16))
                            .foregroundColor(Color("keyBs_white", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(
                        Color("keyBs_bg_red_1", bundle: .module)
                    )
                    .cornerRadius(60)
                }
                .padding(.horizontal, 16)
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [receiptText])
                }
                
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
                    RemoteImage(
                        url: url,
                        placeholder: AnyView(Color.gray.opacity(0.3))
                    )
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
