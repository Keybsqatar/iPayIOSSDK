import UIKit
import SwiftUI

final class KeyboardHeight: ObservableObject {
    @Published var height: CGFloat = 0

    private var willChange: NSObjectProtocol?
    private var willHide:   NSObjectProtocol?

    func start() {
        willChange = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil, queue: .main
        ) { [weak self] n in
            guard let self,
                  let end = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let win = KeyboardHeight.keyWindow else { return }

            let endInWin = win.convert(end, from: nil)
            let overlap  = max(0, win.bounds.maxY - endInWin.minY)
            withAnimation(.easeOut(duration: 0.25)) { self.height = overlap }
        }

        willHide = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil, queue: .main
        ) {
            [weak self] _ in
            withAnimation(.easeOut(duration: 0.25)) { self?.height = 0 }
        }
    }
    
    func stop() {
            if let t = willChange { NotificationCenter.default.removeObserver(t) }
            if let t = willHide   { NotificationCenter.default.removeObserver(t) }
            willChange = nil; willHide = nil
            height = 0
        }

    deinit {
        if let willChange { NotificationCenter.default.removeObserver(willChange) }
        if let willHide   { NotificationCenter.default.removeObserver(willHide) }
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
