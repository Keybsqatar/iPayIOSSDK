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
                        isPresented = false
                        coord.dismissSDK()
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
                        Button(action: { showShareSheet = true }) {
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
                        .sheet(isPresented: $showShareSheet) {
                            ShareSheet(activityItems: [receiptText])
                        }
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
                    .frame(height: 55)
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

