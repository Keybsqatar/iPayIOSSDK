import SwiftUI
import SDWebImageSwiftUI

private class BundleToken {}

public struct DeletionSuccessModalView: View {
    @EnvironmentObject private var coord: SDKCoordinator
    
    /// bind to show/hide
    @Binding var isPresented: Bool
    let message: String
    
    public var body: some View {
        ZStack {
            // Color.black.opacity(0.4)
            //     .ignoresSafeArea()
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 32) {
                // Close button
                HStack {
                    Spacer()
                    Button {
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
                
                VStack(spacing: 24) {
                    // GIF banner
                    if let url = Bundle(for: BundleToken.self)
                        .url(forResource: "summary", withExtension: "gif") {
                        AnimatedImage(url: url)
                            .indicator(.activity)
                        // .resizable()
                            .frame(height: 120) // or whatever height you want
                            .scaledToFit()
                    }
                    
                    Text(message)
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Button(action: { isPresented = false }) {
                        Text("Homepage")
                            .font(.custom("VodafoneRg-Bold", size: 16))
                            .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 56)
                            .padding(.horizontal, 32)
                            .background(Color("keyBs_bg_gray_4", bundle: .module))
                            .cornerRadius(60)
                    }
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(24)
            }
            .padding(.horizontal, 52)
        }
    }
}

#Preview {
    DeletionSuccessModalView(
        isPresented: .constant(true), message: "Bill deleted successfully."
    )
}
