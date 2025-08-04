import UIKit

extension UIApplication {
    /// Walks the view-controller hierarchy to find the one that’s currently visible.
    static func topViewController(
        _ base: UIViewController? = nil
    ) -> UIViewController? {
        // 1) Determine the starting point
        let baseVC: UIViewController? = base
        ?? shared.connectedScenes                  // <-- use `shared`
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        
        guard let vc = baseVC else { return nil }
        
        // 2) Drill into nav controllers
        if let nav = vc as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        // 3) Drill into tab controllers
        if let tab = vc as? UITabBarController {
            return topViewController(tab.selectedViewController)
        }
        // 4) Drill into presented controllers
        if let presented = vc.presentedViewController {
            return topViewController(presented)
        }
        // 5) We found the top
        return vc
    }
}
