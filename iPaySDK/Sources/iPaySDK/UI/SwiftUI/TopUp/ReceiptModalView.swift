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
        return """
        Receipt Details
        Amount: \(data.amount)
        Date:   \(data.dateTime)
        Type:   \(data.type)
        Number: \(data.number)
        Operator: \(data.operatorName)
        Ref ID: \(data.refId)
        """
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
                       coord.closeSDK()
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
                    .padding(.bottom, 32)
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
        let hostVC = UIHostingController(rootView: cardContent)
        let view = hostVC.view!
        let targetSize = view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        snapshotImage = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    
    /// The card content without dim background
    private var cardContent: some View {
        VStack(spacing: 0) {
            // GIF banner
            if let url = Bundle(for: BundleToken.self)
                .url(forResource: "summary", withExtension: "gif") {
                AnimatedImage(url: url)
                    .indicator(.activity)
//                    .resizable()
                    .frame(height: 120) // or whatever height you want
                    .scaledToFit()
            }
            
            //                    Spacer().frame(height: 24)
            
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
            VStack(spacing: 24) {
                detailRow(label: "Type",     value: data.type)
                detailRow(label: "Number",   value: data.number)
                detailRow(label: "Operator", value: data.operatorName)
                
                Divider()
                    .overlay(Color("keyBs_bg_gray_3", bundle: .module))
                
                detailRow(label: "Ref ID",   value: data.refId)
                
                Spacer().frame(height: 24)
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
        //        .padding(.bottom, 24)
        .background(Color.white)
        .cornerRadius(24)
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
            
            Spacer()
            
            Text(value)
                .font(.custom("VodafoneRg-Bold", size: 16))
                .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                .multilineTextAlignment(.leading)
        }
    }
}


#Preview {
    ReceiptModalView(
        isPresented: .constant(true),
        data: ReceiptData(
            amount: "QR 300",
            dateTime: "15 Jul 2024 7:24 AM",
            type: "Top up - IMT",
            number: "92 303 4334334",
            operatorName: "Jazz",
            refId: "1698760015123970"
        )
    )
}

struct ReceiptModalView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        ReceiptModalView(
            isPresented: $isPresented,
            data: ReceiptData(
                amount: "QR 300",
                dateTime: "15 Jul 2024 7:24 AM",
                type: "Top up - IMT",
                number: "92 303 4334334",
                operatorName: "Jazz",
                refId: "1698760015123970"
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
