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
        // var hosting: UIHostingController<AnyView>? = nil
        // let coordinator = SDKCoordinator {
        //     hosting?.dismiss(animated: true)
        // }
        
        // var hosting: UIHostingController<AnyView>? = nil
        // let coordinator = SDKCoordinator(
        //     close: {
        //         hosting?.dismiss(animated: true)
        //     },
        //     popToRoot: {
        //         if let nav = hosting?.navigationController {
        //             nav.popToRootViewController(animated: true)
        //         } else {
        //             hosting?.dismiss(animated: true)
        //         }
        //     }
        // )
        
        var hosting: SDKHostingController<AnyView>? = nil
        // This will be set by TopUpView via a binding
        var popSwiftUI: (() -> Void)? = nil
        
        let coordinator = SDKCoordinator(
            dismiss: {
                hosting?.navigationController?.dismiss(animated: true)
            },
            popSwiftUI: {
                popSwiftUI?()
            }
        )
        
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
        hosting = SDKHostingController(rootView: content)
//        hosting?.navigationController?.setNavigationBarHidden(true, animated: false)
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
        // var hosting: UIHostingController<AnyView>? = nil
        // let coordinator = SDKCoordinator {
        //     hosting?.dismiss(animated: true)
        // }
        
        // var hosting: UIHostingController<AnyView>? = nil
        // let coordinator = SDKCoordinator(
        //     close: {
        //         hosting?.dismiss(animated: true)
        //     },
        //     popToRoot: {
        //         if let nav = hosting?.navigationController {
        //             nav.popToRootViewController(animated: true)
        //         } else {
        //             hosting?.dismiss(animated: true)
        //         }
        //     }
        // )
        
        var hosting: UIHostingController<AnyView>? = nil
        // This will be set by TopUpView via a binding
        var popSwiftUI: (() -> Void)? = nil
        
        let coordinator = SDKCoordinator(
            dismiss: {
                hosting?.navigationController?.dismiss(animated: true)
            },
            popSwiftUI: {
                popSwiftUI?()
            }
        )
        
        
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
//        hosting?.navigationController?.setNavigationBarHidden(true, animated: false)
        return hosting!
    }
    
    @MainActor
    public static func openViewVoucherController(
        secretKey:      String,
        serviceCode:    String,
        mobileNumber:   String,
        iPayCustomerID: String,
        billingRef:    String
    ) -> UIViewController? {
        // 1) Fonts & networking
        FontLoader.registerFonts()
        HTTPClient.shared.initialize(secretKey: secretKey)
        
        // 2) Coordinator for dismissal
        var hosting: UIHostingController<AnyView>? = nil
        // This will be set by TopUpView via a binding
        var popSwiftUI: (() -> Void)? = nil
        
        let coordinator = SDKCoordinator(
            dismiss: {
                hosting?.navigationController?.dismiss(animated: true)
            },
            popSwiftUI: {
                popSwiftUI?()
            }
        )
        
        
        // 3) Build the SwiftUI view
        let content: AnyView
        switch serviceCode {
        case "INT_VOUCHER":
            content = AnyView(
                OpenViewVoucherView(vm: OpenViewVoucherViewModel(
                    serviceCode:    serviceCode,
                    mobileNumber:   mobileNumber,
                    iPayCustomerID: iPayCustomerID,
                    billingRef:    billingRef
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
