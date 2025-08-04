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
