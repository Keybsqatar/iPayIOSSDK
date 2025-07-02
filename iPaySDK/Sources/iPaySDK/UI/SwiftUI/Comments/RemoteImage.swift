import SwiftUI

struct RemoteImage: View {
    @ObservedObject private var loader: ImageLoader
    var placeholder: AnyView

    init(url: URL?, placeholder: AnyView = AnyView(Color.gray.opacity(0.3))) {
        self.loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
        .onAppear {
            loader.load()
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private static let cache = NSCache<NSURL, UIImage>()
    private let url: URL?

    init(url: URL?) {
        self.url = url
        load()
    }

    func load() {
        guard let url = url else {
            self.image = nil
            return
        }
        if let cached = Self.cache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    Self.cache.setObject(img, forKey: url as NSURL)
                    self.image = img
                }
            }
        }.resume()
    }
}
