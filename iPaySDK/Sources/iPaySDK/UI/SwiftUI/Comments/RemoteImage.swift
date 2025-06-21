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
                AnyView(
                    Image(uiImage: image)
                        .resizable()
                )
            } else {
                placeholder
            }
        }
        .onAppear { loader.load() }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    func load() {
        guard let url = url, image == nil else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }.resume()
    }
}
