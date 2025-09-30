
import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    let name: String
    let bundle: Bundle

    public init(name: String, bundle: Bundle = .main) {
        self.name = name
        self.bundle = bundle
    }

    public func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop

        // Load from the provided bundle (SPM => .module)
        if let anim = LottieAnimation.named(name, bundle: bundle) {
            view.animation = anim
            view.play()
        } else {
            // Helpful debug
            print("⚠️ Lottie not found: \(name) in \(bundle.bundlePath)")
        }
        return view
    }

    public func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

