import SwiftUI
import SDWebImageSwiftUI

private class BundleToken {}

public struct OtpAlertModalView: View {
    @EnvironmentObject private var coord: SDKCoordinator
    
    /// bind to show/hide
    @Binding var isPresented: Bool
    let message: String
    var onHomepage: (() -> Void)? = nil
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 32) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        //coord.dismissSDK()
                        isPresented = false
                        onHomepage?()

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
                    if let url = Bundle.module.url(forResource: "oops", withExtension: "gif") {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 56)
                    }
                    
                    Text(message)
                        .font(.custom("VodafoneRg-Regular", size: 16))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Button(action: {
                        isPresented = false
                        onHomepage?()
                    }) {
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
    OtpAlertModalView(
        isPresented: .constant(true), message: "Bill deleted successfully."
    )
}
