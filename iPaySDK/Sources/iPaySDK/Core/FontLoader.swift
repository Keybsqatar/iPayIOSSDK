import Foundation
import CoreText

public enum FontLoader {
    public static func registerFonts() {
        let bundle = Bundle.mySwiftUIPackage
        // List all .ttf (or .otf) you expect
        let fontNames = [
//            "Vodafone-Lt",
            "Vodafone-Rg",
            "Vodafone-RgBd"
        ]  // drop the extension
        
        for name in fontNames {
            guard let url = bundle.url(forResource: name, withExtension: "ttf")
                    ?? bundle.url(forResource: name, withExtension: "otf")
            else {
                print("🚨 FontLoader: -- could not find \(name).ttf/.otf in bundle")
                continue
            }
            
            // Debug: print PostScript name inside the file
            
            if let data = try? Data(contentsOf: url),
               let provider = CGDataProvider(data: data as CFData),
               let cgFont = CGFont(provider)
            {
                let psName = cgFont.postScriptName as String? ?? "unknown"
//                print("FontLoader: found font file \(name) with PostScript name: \(psName)")
                print("FontLoader: file \(name) - PostScript name: \(psName)")
            }
            
            var errorRef: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(
                url as CFURL,
                .process,
                &errorRef
            )
            if !success {
//                let err = errorRef?.takeRetainedValue().localizedDescription ?? "unknown error"
//                print("🚨 FontLoader: failed to register \(name): \(err)")
            } else {
//                print("✅ FontLoader: registered \(name)")
            }
        }
    }
}

