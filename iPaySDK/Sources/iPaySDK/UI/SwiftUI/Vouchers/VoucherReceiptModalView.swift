import SwiftUI
import Photos
import UIKit
import SDWebImageSwiftUI

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

private class BundleToken {}

public struct VoucherReceiptModalView: View {
    @EnvironmentObject private var coord: SDKCoordinator
    
    @Binding var isPresented: Bool
    let data: ReceiptData
    
    // MARK: – Internal state
    @State private var snapshotImage: UIImage?
    @State private var savedError: String?
    @State private var showShareSheet = false
    @State private var showView = false
    
    @State private var shareImage: UIImage? = nil
    @State private var isSharing = false
    
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle  = .medium
        f.timeStyle  = .short
        return f
    }()
    
    /// Build the plain‐text summary for sharing
    private var receiptText: String {
        var details = """
        Receipt Details
        Amount: \(data.amount)
        Date:   \(data.dateTime)
        Type: \(data.type)
        Voucher: \(data.product.displayText)
        Country: \(data.countryName)
        Ref ID: \(data.refId)
        """
        
        return details
    }
    
    public var body: some View {
        ZStack {
            // Dimmed backdrop
            Color("keyBs_bg_gray_4", bundle: .module).opacity(0.9)
            // .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 32) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        coord.dismissSDK()
                        //isPresented = false
                    } label: {
                        Image("ic_close", bundle: .module)
                            .frame(width: 16, height: 16)
                            .scaledToFit()
                    }
                    .frame(width: 32, height: 32)
                    .background(
                        Color.white
                            .clipShape(Circle())
                    )
                }
                
                // Card
                VStack(spacing: 0){
                    cardContent
                    
                    VStack(spacing: 8){
                        // View Receipt button
                        Button(action: { showView = true }) {
                            Text("View Voucher")
                                .font(.custom("VodafoneRg-Bold", size: 16))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color("keyBs_bg_gray_4", bundle: .module))
                                .cornerRadius(60)
                        }
                        .disabled(data.status == "SUCCESS" ? false : true)
                        NavigationLink(
                            destination: Group {
                                ViewVoucherView(
                                    close: true,
                                    displayText: data.product.displayText,
                                    countryFlagUrl: data.countryFlagUrl,
                                    countryName: data.countryName,
                                    providerName: data.providerName,
                                    providerLogoUrl: data.providerLogoUrl,
                                    dateTime: data.dateTime,
                                    refId: data.refId,
                                    
                                    descriptionMarkdown:  data.descriptionMarkdown,
                                    readMoreMarkdown: data.readMoreMarkdown,
                                    
                                    textPin: data.textPin,
                                    valuePin: data.valuePin
                                )
                                .environmentObject(coord)
                                .navigationBarHidden(true)
                                
                            },
                            isActive: $showView,
                            label: { EmptyView() }
                        )
                        .hidden()
                        .allowsHitTesting(false)     // ← add this line

                        
                        // Share Receipt button
                        Button(action: { shareReceipt()}) {
                            HStack(spacing: 8) {
                                Image("ic_share", bundle: .module)
                                    .frame(width: 24, height: 24)
                                    .scaledToFit()
                                
                                Text("Share Receipt")
                                    .font(.custom("VodafoneRg-Bold", size: 16))
                                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(
                                Color("keyBs_white", bundle: .module)
                            )
                            .cornerRadius(60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 60, style: .continuous)
                                    .stroke(
                                        Color("keyBs_font_gray_2", bundle: .module),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .sheet(
                                isPresented: Binding(
                                    get: { isSharing && shareImage != nil },
                                    set: { if !$0 { isSharing = false; shareImage = nil } }
                                )
                            ) {
                                // shareImage! is safe because of the binding guard above
                                ShareSheet(activityItems: [shareImage!])
                        }
//                        .sheet(isPresented: $showShareSheet) {
//                            ShareSheet(activityItems: [receiptText])
//                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .background(Color.white)
                }
                .background(Color.white)
                .cornerRadius(24)
                
            }
            .padding(.horizontal, 52)
        }
    }
    
    @MainActor
    private func shareReceipt() {
        if let img = makeReceiptImage() {
            shareImage = img
            isSharing = true
        } else {
            // optional: show a toast/alert if capture failed
            // toastMessage = "Couldn’t create snapshot"
        }
    }
    @MainActor
    private func makeReceiptImage() -> UIImage? {
        let cardWidth: CGFloat = 340
        let content = cardContent
            .frame(width: cardWidth)
            .fixedSize(horizontal: false, vertical: true)

        // iOS 16+: SwiftUI-native renderer (best quality)
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: content)
            renderer.scale = UIScreen.main.scale
            renderer.isOpaque = false
            return renderer.uiImage
        }

        // iOS 13–15: render a UIHostingController off-screen
        let host = UIHostingController(rootView: content)
        let view = host.view!
        view.backgroundColor = .clear

        // Put the view in a sizing container so Auto Layout can resolve its height
        let container = UIView(frame: CGRect(origin: .zero, size: .zero))
        container.backgroundColor = .clear
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.widthAnchor.constraint(equalToConstant: cardWidth)   // key for correct height
        ])

        // Force layout to get the final size
        container.setNeedsLayout()
        container.layoutIfNeeded()

        // Compute the fitting height now that constraints are set
        let targetSize = container.systemLayoutSizeFitting(
            CGSize(width: cardWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        container.frame = CGRect(origin: .zero, size: targetSize)
        view.frame = container.bounds

        // Render (layer.render is more reliable than drawHierarchy for off-screen)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let image = renderer.image { ctx in
            container.layer.render(in: ctx.cgContext)
        }

        return image
    }
    
    private func captureSnapshot() {
        let cardWidth: CGFloat = 340
        
        let hostVC = UIHostingController(rootView:
                                            cardContent
            .frame(width: cardWidth)
            .fixedSize(horizontal: false, vertical: true) // <-- Add this line
        )
        let view = hostVC.view!
        view.backgroundColor = .clear
        
        // Use systemLayoutSizeFitting to get the correct height
        let targetSize = view.systemLayoutSizeFitting(
            CGSize(width: cardWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        view.bounds = CGRect(origin: .zero, size: targetSize)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        snapshotImage = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    
    private var cardContent: some View {
        VStack(spacing: 0) {
            // GIF banner
            if let url = Bundle.module.url(forResource: data.status == "SUCCESS" ? "summary" : data.status == "PROCESSING" ? "transaction_in_progress" : "transaction_failed", withExtension: "gif") {
                AnimatedImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(idealWidth: 215, maxHeight: 75)
            }

            // Amount & date
            VStack(spacing: 8) {
                Text(data.amount)
                    .font(.custom("VodafoneRg-Bold", size: 32))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
                
                Text(data.dateTime)
                    .font(.custom("VodafoneRg-Regular", size: 14))
                    .foregroundColor(Color("keyBs_font_gray_5", bundle: .module))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer().frame(height: 24)
            
            // Details card
            VStack(spacing: 16) {
                detailRow(label: "Type",     value: data.type)
                
                detailRow(label: "Voucher",     value: data.product.displayText)
                
                detailRow(label: "Country",     value: data.countryName)
                
                Divider()
                    .overlay(Color("keyBs_bg_gray_3", bundle: .module))
                
                detailRow(label: "iPay Ref ID",   value: data.refId)
                
                Spacer().frame(height: 16)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        //        .padding(.bottom, 24)
        .background(Color.white)
        .cornerRadius(24)
    }
    
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.custom("VodafoneRg-Regular", size: 16))
                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                .multilineTextAlignment(.leading)
            
            if !value.isEmpty{
                Spacer()
                
                Text(value)
                    .font(.custom("VodafoneRg-Bold", size: 16))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
            }
            
        }
    }
}

