// DoneAccessoryTextField.swift
import SwiftUI
import UIKit

/// A UIKit-backed text field that shows a keyboard toolbar with a "Done" button.
/// Works on iOS 13+ (no FocusState required).
public struct DoneAccessoryTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var onEditingChanged: ((Bool) -> Void)? = nil
    var onCommit: (() -> Void)? = nil

    public init(text: Binding<String>,
                placeholder: String = "",
                keyboardType: UIKeyboardType = .default,
                onEditingChanged: ((Bool) -> Void)? = nil,
                onCommit: (() -> Void)? = nil) {
        _text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }

    public func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.delegate = context.coordinator
        tf.keyboardType = keyboardType
        tf.placeholder = placeholder
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)

        // Add toolbar with "Done"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done,
                                   target: context.coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.items = [flex, done]
        tf.inputAccessoryView = toolbar

        // Appearance: let SwiftUI style it (font/color) via `.foregroundColor`, `.font` etc.
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        return tf
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text { uiView.text = text }
        if uiView.placeholder != placeholder { uiView.placeholder = placeholder }
        uiView.keyboardType = keyboardType
    }

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DoneAccessoryTextField
        init(_ parent: DoneAccessoryTextField) { self.parent = parent }

        @objc func textChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }

        @objc func doneTapped() {
            // Dismiss keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
            parent.onCommit?()
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged?(true)
        }
        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged?(false)
        }
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            doneTapped()
            return true
        }
    }
}
