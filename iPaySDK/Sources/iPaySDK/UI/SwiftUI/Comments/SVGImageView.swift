import SwiftUI
import SVGKit

/// SwiftUI view that loads & renders an SVG from a URL
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
        .onChange(of: url) { _,_ in
            loadSVG()
        }
    }
    
    private func loadSVG() {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let svgImage = SVGKImage(data: data)
            else { return }
            DispatchQueue.main.async {
                uiImage = svgImage.uiImage
            }
        }.resume()
    }
}
