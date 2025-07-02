import SwiftUI
import SVGKit
import Combine

fileprivate class SVGImageCache {
    static let shared = SVGImageCache()
    private var cache = NSCache<NSURL, UIImage>()
    
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

struct SVGImageView: View {
    let url: URL
    @State private var uiImage: UIImage?
    
    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
            } else {
                // placeholder
                Color.gray.opacity(0.3)
            }
        }
        .onAppear(perform: loadSVG)
        .onReceive(Just(url)) { _ in
            loadSVG()
        }
    }
    
    private func loadSVG() {
        if let cached = SVGImageCache.shared.image(for: url) {
            uiImage = cached
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                guard let svgImage = SVGKImage(data: data),
                      let image = svgImage.uiImage else { return }
                SVGImageCache.shared.setImage(image, for: url)
                DispatchQueue.main.async {
                    uiImage = image
                }
            }
        }.resume()
    }
}
