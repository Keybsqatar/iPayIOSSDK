import SwiftUI
import UIKit

public struct iPaySDK {
    /// Only function your host app calls.
    /// Wraps the SwiftUI TopUpView in a UIHostingController.
    @MainActor
    public static func makeTopUpController(
        secretKey: String,
        serviceCode: String,
        mobileNumber: String,
        iPayCustomerID: String
    ) -> UIViewController {
        // 1) Fonts & networking
        FontLoader.registerFonts()
        HTTPClient.shared.initialize(secretKey: secretKey)
        
        // 2) Coordinator for dismissal
        var hosting: UIHostingController<AnyView>? = nil
        let coordinator = SDKCoordinator {
            hosting?.dismiss(animated: true)
        }
        
        // 3) Build the SwiftUI view
        let content = AnyView(
            TopUpView(
                mobileNumber: mobileNumber,
                serviceCode:  serviceCode,
                iPayCustomerID: iPayCustomerID
            )
            .environmentObject(coordinator)
        )
        
        // 4) Wrap and return
        hosting = UIHostingController(rootView: content)
        return hosting!
    }
    
    @MainActor
    public static func makeOpenSavedController(
        secretKey:      String,
        serviceCode:    String,
        mobileNumber:   String,
        iPayCustomerID: String,
        savedBillID:    String
    ) -> UIViewController {
        // 1) Fonts & networking
        FontLoader.registerFonts()
        HTTPClient.shared.initialize(secretKey: secretKey)
        
        // 2) Coordinator for dismissal
        var hosting: UIHostingController<AnyView>? = nil
        let coordinator = SDKCoordinator {
            hosting?.dismiss(animated: true)
        }
        
        // 3) Build the SwiftUI view
        let vm = OpenSavedTopupViewModel(
            serviceCode:    serviceCode,
            mobileNumber:   mobileNumber,
            iPayCustomerID: iPayCustomerID,
            savedBillID:    savedBillID
        )
        let content = AnyView(
            OpenSavedTopupView(vm: vm)
                .environmentObject(coordinator)
        )
        
        // 4) Wrap and return
        hosting = UIHostingController(rootView: content)
        return hosting!
    }
}
