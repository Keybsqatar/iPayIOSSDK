import SwiftUI
import UIKit

public enum iPaySDKError: Error {
    case invalidServiceCode(String)
}

public struct iPaySDK {
    /// Only function your host app calls.
    /// Wraps the SwiftUI TopUpView in a UIHostingController.
    
    @MainActor
    public static func startServiceTypeController(
        secretKey: String,
        serviceCode: String,
        mobileNumber: String,
        iPayCustomerID: String
    ) -> UIViewController? {
        // 1) Fonts & networking
        FontLoader.registerFonts()
        HTTPClient.shared.initialize(secretKey: secretKey)
        
        // 2) Coordinator for dismissal
        var hosting: UIHostingController<AnyView>? = nil
        let coordinator = SDKCoordinator {
            hosting?.dismiss(animated: true)
        }
        
        // 3) Build the SwiftUI view
        let content: AnyView
        switch serviceCode {
        case "INT_TOP_UP":
            content = AnyView(
                TopUpView(
                    mobileNumber: mobileNumber,
                    serviceCode:  serviceCode,
                    iPayCustomerID: iPayCustomerID
                )
                .environmentObject(coordinator)
            )
        case "INT_VOUCHER":
            content = AnyView(
                VouchersView(
                    mobileNumber: mobileNumber,
                    serviceCode:  serviceCode,
                    iPayCustomerID: iPayCustomerID
                )
                .environmentObject(coordinator)
            )
        case "INT_UTIL_PAYMENT":
            content = AnyView(
                UtilityView(
                    mobileNumber: mobileNumber,
                    serviceCode:  serviceCode,
                    iPayCustomerID: iPayCustomerID
                )
                .environmentObject(coordinator)
            )
        default:
            return nil // <-- Do nothing
            
        }
        
        // 4) Wrap and return
        hosting = UIHostingController(rootView: content)
        return hosting!
    }
    
    @MainActor
    public static func openSavedTopUpController(
        secretKey:      String,
        serviceCode:    String,
        mobileNumber:   String,
        iPayCustomerID: String,
        savedBillID:    String
    ) -> UIViewController? {
        // 1) Fonts & networking
        FontLoader.registerFonts()
        HTTPClient.shared.initialize(secretKey: secretKey)
        
        // 2) Coordinator for dismissal
        var hosting: UIHostingController<AnyView>? = nil
        let coordinator = SDKCoordinator {
            hosting?.dismiss(animated: true)
        }
        
        // 3) Build the SwiftUI view
        let content: AnyView
        switch serviceCode {
        case "INT_TOP_UP":
            content = AnyView(
                OpenSavedTopupView(vm: OpenSavedTopupViewModel(
                    serviceCode:    serviceCode,
                    mobileNumber:   mobileNumber,
                    iPayCustomerID: iPayCustomerID,
                    savedBillID:    savedBillID
                ))
                .environmentObject(coordinator)
            )
        default:
            return nil // <-- Do nothing
            
        }
        
        // 4) Wrap and return
        hosting = UIHostingController(rootView: content)
        return hosting!
    }
}
