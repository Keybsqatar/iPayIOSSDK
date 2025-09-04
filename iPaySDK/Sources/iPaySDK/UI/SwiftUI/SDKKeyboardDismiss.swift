//
//  SDKKeyboardDismiss.swift
//  iPaySDK
//
//  Created by Loay Abdullah on 21/08/2025.
//

import UIKit
import SwiftUI

// Works across multi-scene apps (iOS 13+)
extension UIApplication {
    static func sdkDismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
        UIApplication.shared.endEditing()
    }
}

// A modifier that wins the gesture race on real devices
struct SDKDismissOnBackgroundTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.sdkDismissKeyboard()
            }
            .simultaneousGesture(TapGesture().onEnded {
                UIApplication.sdkDismissKeyboard()
            })
//            .highPriorityGesture(TapGesture().onEnded(
//                {
//                    _ in
//                    UIApplication.sdkDismissKeyboard()
//                }
//            ))
            
//            .highPriorityGesture(DragGesture(minimumDistance: 1).onChanged { _ in
//                UIApplication.sdkDismissKeyboard()
//            })
    }
}

extension View {
    /// Call this on your outermost container
    func sdkDismissKeyboardOnTap() -> some View {
        modifier(SDKDismissOnBackgroundTap())
    }
}
