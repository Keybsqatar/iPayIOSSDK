import SwiftUI

/// A simple toast overlay that appears at the bottom, then auto-dismisses.
struct ToastModifier: ViewModifier {
    /// Bound flag for showing / hiding
    @Binding var isShowing: Bool
    /// The message to display
    let message: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if isShowing {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        // auto-dismiss after 2s
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { isShowing = false }
                        }
                    }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
