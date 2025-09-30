import Foundation
import Combine     // ← add this

final class SDKCoordinator: ObservableObject {
    private let dismissAction: @MainActor () -> Void
    private let popSwiftUIAction: @MainActor () -> Void

    init(dismiss: @escaping @MainActor () -> Void,
         popSwiftUI: @escaping @MainActor () -> Void) {
        self.dismissAction = dismiss
        self.popSwiftUIAction = popSwiftUI
    }

    @MainActor func dismissSDK() {
        //print("[SDK] dismiss tapped")
        dismissAction()
    }

    @MainActor func popSwiftUIScreen() {
        popSwiftUIAction()
    }
}

