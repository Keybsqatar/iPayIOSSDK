// import SwiftUI

// struct FocusableTextField: UIViewRepresentable {
//     class Coordinator: NSObject, UITextFieldDelegate {
//         var parent: FocusableTextField
//         init(_ parent: FocusableTextField) { self.parent = parent }
//         func textFieldDidChangeSelection(_ textField: UITextField) {
//             parent.text = textField.text ?? ""
//         }
//     }

//     @Binding var text: String
//     var isFirstResponder: Bool = false
//     var keyboardType: UIKeyboardType = .default

//     func makeUIView(context: Context) -> UITextField {
//         let textField = UITextField()
//         textField.delegate = context.coordinator
//         textField.keyboardType = keyboardType
//         textField.isSecureTextEntry = false
//         textField.text = text
//         return textField
//     }

//     func updateUIView(_ uiView: UITextField, context: Context) {
//         uiView.text = text
//         if isFirstResponder && !uiView.isFirstResponder {
//             uiView.becomeFirstResponder()
//         }
//     }

//     func makeCoordinator() -> Coordinator {
//         Coordinator(self)
//     }
// }
