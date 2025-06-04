import Foundation
import Combine     // ← add this

/// Passed into your SwiftUI tree so any view can close the SDK
public class SDKCoordinator: ObservableObject {
  let closeSDK: @MainActor () -> Void
  public init(closeSDK: @escaping @MainActor () -> Void) {
    self.closeSDK = closeSDK
  }
}
