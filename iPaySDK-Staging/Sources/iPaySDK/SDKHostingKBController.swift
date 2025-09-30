//
//  SDKHostingKBController.swift
//  iPaySDK
//
//  Created by Loay Abdullah on 21/08/2025.
//

// SDKHostingController.swift
import SwiftUI
import UIKit

public final class SDKHostingKBController<Content: View>: UIHostingController<Content> {
    private let accessory = KeyboardAccessory()
    private var accessoryBottom: NSLayoutConstraint!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // accessory view (blur + Done button)
        accessory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(accessory)
        accessoryBottom = accessory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            accessory.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            accessory.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            accessory.heightAnchor.constraint(equalToConstant: 44),
            accessoryBottom
        ])
        accessory.isHidden = true
        accessory.onDone = { [weak self] in
            self?.view.endEditing(true)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        // keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(kbChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide(_:)),   name: UIResponder.keyboardWillHideNotification,         object: nil)
    }

    @objc private func kbChange(_ n: Notification) {
        guard
            let ui = n.userInfo,
            let end = ui[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let dur = ui[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = ui[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        // convert keyboard frame to our view
        let endInView = view.convert(end, from: nil)
        let overlap = max(0, view.bounds.maxY - endInView.minY) // how much keyboard covers bottom
        accessory.isHidden = overlap == 0
        accessoryBottom.constant = -overlap                     // sit right above keyboard

        UIView.animate(withDuration: dur,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveRaw << 16),
                       animations: { self.view.layoutIfNeeded() })
    }

    @objc private func kbHide(_ n: Notification) {
        accessory.isHidden = true
        accessoryBottom.constant = 0
        let dur = (n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        UIView.animate(withDuration: dur) { self.view.layoutIfNeeded() }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// Simple blur bar with a trailing "Done"
final class KeyboardAccessory: UIView {
    var onDone: (() -> Void)?

    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let button: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(blur); blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button); button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),

            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        button.addTarget(self, action: #selector(tapDone), for: .touchUpInside)
    }
    @objc private func tapDone() { onDone?() }
    required init?(coder: NSCoder) { fatalError() }
}
