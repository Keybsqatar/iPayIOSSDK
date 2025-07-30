import Foundation
import Combine     // ← add this

final class SDKCoordinator: ObservableObject {
    private let dismissAction: () -> Void
    private let popSwiftUIAction: () -> Void
    
    init(dismiss: @escaping () -> Void, popSwiftUI: @escaping () -> Void) {
        self.dismissAction = dismiss
        self.popSwiftUIAction = popSwiftUI
    }
    
    func dismissSDK() {
        dismissAction()
    }
    
    func popSwiftUIScreen() {
        popSwiftUIAction()
    }
}

// final class SDKCoordinator: ObservableObject {
//     private let closeAction: () -> Void
//     private let popToRootAction: () -> Void

//     init(close: @escaping () -> Void, popToRoot: @escaping () -> Void) {
//         self.closeAction = close
//         self.popToRootAction = popToRoot
//     }

//     func closeSDK() {
//         popToRootAction()
//     }
// }

/// Passed into your SwiftUI tree so any view can close the SDK
// public class SDKCoordinator: ObservableObject {
//   let closeSDK: @MainActor () -> Void
//   public init(closeSDK: @escaping @MainActor () -> Void) {
//     self.closeSDK = closeSDK
//   }
// }
