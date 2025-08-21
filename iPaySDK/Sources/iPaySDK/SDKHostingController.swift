//
//  SDKHostingController.swift
//  iPaySDK
//
//  Created by Loay Abdullah on 21/08/2025.
//

import SwiftUI
import UIKit

/// Hosting controller that politely dismisses the keyboard on any background tap/drag.
/// Uses gesture recognizers so it won’t swallow button taps or interfere with scrolling.
public final class SDKHostingController<Content: View>: UIHostingController<Content> {

    public override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delaysTouchesEnded = false
        view.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        pan.cancelsTouchesInView = false
        view.addGestureRecognizer(pan)
    }

    @objc private func dismissKeyboard() {
        // End editing for anything currently first-responder in this hierarchy
        view.endEditing(true)
        // Extra belt: ask the app to resign if some responder lives outside our view
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
