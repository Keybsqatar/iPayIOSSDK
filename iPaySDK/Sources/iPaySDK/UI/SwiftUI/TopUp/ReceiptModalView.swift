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

public struct ReceiptModalView: View {
    @EnvironmentObject private var coord: SDKCoordinator
    
    @Binding var isPresented: Bool
    let data: ReceiptData
    
    // MARK: – Internal state
    @State private var snapshotImage: UIImage?
    @State private var showSavedAlert = false
    @State private var savedError: String?
    @State private var showShareSheet = false
    
    
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
        Type:   \(data.type)
        Number: \(data.number)
        Operator: \(data.operatorName)
        Ref ID: \(data.refId)
        """
        
        if !data.textPin.isEmpty, !data.valuePin.isEmpty, data.status == "SUCCESS" {
            details += "\n\(data.textPin.uppercased()): \(data.valuePin)"
        }
        
        if !data.descriptionMarkdown.isEmpty || !data.readMoreMarkdown.isEmpty, data.status == "SUCCESS" {
            if !data.readMoreMarkdown.isEmpty {
                details += "\n Key Information: \(data.readMoreMarkdown)"
            }else {
                details += "\n Key Information: \(data.descriptionMarkdown)"
            }
        }
        
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
                    
                    //                    Spacer().frame(height: 24)
                    
                    VStack(spacing: 16){
                        // Download Receipt button
                        Button(action: downloadReceipt) {
                            Text("Download Receipt")
                                .font(.custom("VodafoneRg-Bold", size: 16))
                                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color("keyBs_bg_gray_4", bundle: .module))
                                .cornerRadius(60)
                            
                        }
                        .alert(isPresented: $showSavedAlert) {
                            if let err = savedError {
                                return Alert(
                                    title: Text("Error"),
                                    message: Text(err),
                                    dismissButton: .default(Text("OK"))
                                )
                            } else {
                                return Alert(
                                    title: Text("Saved!"),
                                    message: Text("Receipt saved to Photos."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }
                        
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
                            //                            .background(
                            //                                RoundedRectangle(cornerRadius: 60)
                            //                                    .fill(Color("keyBs_white", bundle: .module))
                            //                                    .stroke(
                            //                                        Color("keyBs_font_gray_2", bundle: .module)
                            //                                        ,
                            //                                        lineWidth: 1
                            //                                    )
                            //                            )
                            .background(
                                Color("keyBs_white", bundle: .module)
                            )
                            // 2) rounded corners
                            .cornerRadius(60)
                            // 3) border overlay
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
            //                        .onAppear(perform: captureSnapshot)
        }
    }
    
    /// Renders the card (without overlay) into `snapshotImage`
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
    
    /// The card content without dim background
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
                detailRow(label: "Number",   value: data.number)
                detailRow(label: "Operator", value: data.operatorName)
                
                Divider()
                    .overlay(Color("keyBs_bg_gray_3", bundle: .module))
                
                detailRow(label: "Ref ID",   value: data.refId)
                
                if !data.textPin.isEmpty, !data.valuePin.isEmpty, data.status == "SUCCESS" {
                    Divider()
                        .overlay(Color("keyBs_bg_gray_3", bundle: .module))
                    
                    detailRow(label: data.textPin.uppercased(), value: data.valuePin)
                }
                /*
                if !data.descriptionMarkdown.isEmpty || !data.readMoreMarkdown.isEmpty, data.status == "SUCCESS" {
                    Divider()
                        .overlay(Color("keyBs_bg_gray_3", bundle: .module))
                    
                    AccordionView(
                        title: "Key Information",
                        content: {
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(spacing: 0){
                                    Text(!data.readMoreMarkdown.isEmpty ? data.readMoreMarkdown : data.descriptionMarkdown)
                                        .font(.custom("VodafoneRg-Regular", size: 14))
                                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.bottom, 8)
                                .padding(.horizontal, 12)
                            }
                            .frame(maxHeight: 100)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    )
                }
                 */
                
                Spacer().frame(height: 16)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        //        .padding(.bottom, 24)
        .background(Color.white)
        .cornerRadius(24)
    }
    
    struct AccordionView<Content: View>: View {
        let title: String
        @ViewBuilder let content: Content
        @State private var expanded = true
        
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
                            .frame(width: 12, height: 12)
                    }
                    .padding(.all, 12)
                }
                
                if expanded {
                    content
                }
            }
            .background(Color("keyBs_bg_gray_7", bundle: .module))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    /// Saves the rendered snapshot into the Photos library.
    private func downloadReceipt() {
        captureSnapshot()
        guard let img = snapshotImage else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            // guard status == .authorized || status == .limited else {
            //     DispatchQueue.main.async {
            //         savedError     = "Photo Library access denied."
            //         showSavedAlert = true
            //     }
            //     return
            // }
            guard status == .authorized else {
                DispatchQueue.main.async {
                    savedError     = "Photo Library access denied."
                    showSavedAlert = true
                }
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if !success {
                        savedError = error?.localizedDescription
                    }
                    showSavedAlert = true
                }
            }
        }
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

