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

        FontLoader.registerFonts()
        HTTPClient.shared.initialize(secretKey: secretKey)

        final class NavHolder { weak var nav: UINavigationController? }
            let holder = NavHolder()

            let coordinator = SDKCoordinator(
                dismiss: { [holder] in                     // <- strong capture
                    guard let nav = holder.nav else {
                        //print("[SDK] dismiss: nav is nil")
                        return
                    }
                    if nav.presentingViewController != nil {
                        nav.dismiss(animated: false)        // presented → close whole SDK
                    } else {
                        nav.popViewController(animated: false) // pushed → pop
                    }
                },
                popSwiftUI: { [holder] in
                    holder.nav?.popViewController(animated: true)
                }
            )

            let content: AnyView = {
                switch serviceCode {
                case "INT_TOP_UP":
                    return AnyView(TopUpView(mobileNumber: mobileNumber,
                                             serviceCode: serviceCode,
                                             iPayCustomerID: iPayCustomerID)
                        .environmentObject(coordinator))
                case "INT_VOUCHER":
                    return AnyView(VouchersView(mobileNumber: mobileNumber,
                                                serviceCode: serviceCode,
                                                iPayCustomerID: iPayCustomerID)
                        .environmentObject(coordinator))
                case "INT_UTIL_PAYMENT":
                    return AnyView(UtilityView(mobileNumber: mobileNumber,
                                               serviceCode: serviceCode,
                                               iPayCustomerID: iPayCustomerID)
                        .environmentObject(coordinator))
                default:
                    return AnyView(EmptyView())
                }
            }()

            let hosting = UIHostingController(rootView: content)
//        let sdkNav  = UINavigationController(rootViewController: hosting)
        let sdkNav  = SDKNavigationController(rootViewController: hosting)
            sdkNav.modalPresentationStyle = .fullScreen

            holder.nav = sdkNav            // assign AFTER creating it
            return sdkNav
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
        
        final class NavHolder { weak var nav: UINavigationController? }
            let holder = NavHolder()

            let coordinator = SDKCoordinator(
                dismiss: { [holder] in                     // <- strong capture
                    guard let nav = holder.nav else {
                        //print("[SDK] dismiss: nav is nil")
                        return
                    }
                    if nav.presentingViewController != nil {
                        nav.dismiss(animated: true)        // presented → close whole SDK
                    } else {
                        nav.popViewController(animated: true) // pushed → pop
                    }
                },
                popSwiftUI: { [holder] in
                    holder.nav?.popViewController(animated: true)
                }
            )
        
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
        let hosting = UIHostingController(rootView: content)
//        let sdkNav  = UINavigationController(rootViewController: hosting)
        let sdkNav  = SDKNavigationController(rootViewController: hosting)
        sdkNav.modalPresentationStyle = .fullScreen

        holder.nav = sdkNav            // assign AFTER creating it
        return sdkNav
        /*
        
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
         */
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
        
        final class NavHolder { weak var nav: UINavigationController? }
            let holder = NavHolder()

            let coordinator = SDKCoordinator(
                dismiss: { [holder] in                     // <- strong capture
                    guard let nav = holder.nav else {
                        //print("[SDK] dismiss: nav is nil")
                        return
                    }
                    if nav.presentingViewController != nil {
                        nav.dismiss(animated: true)        // presented → close whole SDK
                    } else {
                        nav.popViewController(animated: true) // pushed → pop
                    }
                },
                popSwiftUI: { [holder] in
                    holder.nav?.popViewController(animated: true)
                }
            )
        
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
        let hosting = UIHostingController(rootView: content)
//        let sdkNav  = UINavigationController(rootViewController: hosting)
        let sdkNav  = SDKNavigationController(rootViewController: hosting)
        sdkNav.modalPresentationStyle = .fullScreen

        holder.nav = sdkNav            // assign AFTER creating it
        return sdkNav
        /*
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
        return hosting!*/
    }
}
