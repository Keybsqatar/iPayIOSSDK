import SwiftUI
import SVGKit
import Combine

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
        // .onChange(of: url) { _ in
        //     loadSVG()
        // }
        .onReceive(Just(url)) { _ in
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
    
    //      private func loadSVG() {
    //          URLSession.shared.dataTask(with: url) { data, _, error in
    //              guard let data = data, error == nil else {
    //                  print("Error loading SVG: \(error?.localizedDescription ?? "Unknown error")")
    //                  return
    //              }
    //
    //              do {
    //                  guard let svgImage = SVGKImage(data: data) else {
    //                      print("Failed to parse SVG data. Ensure the SVG file is valid and doesn't contain unsupported elements.")
    //                      return
    //                  }
    //
    //                  DispatchQueue.main.async {
    //                      uiImage = svgImage.uiImage
    //                  }
    //              } catch {
    //                  print("Exception during SVG parsing: \(error.localizedDescription)")
    //              }
    //          }.resume()
    //      }
}
//
//import SwiftUI
//import SDWebImageSwiftUI
//import SDWebImageSVGCoder
//
//struct SVGImageView: View {
//    let url: URL
//
//    init(url: URL) {
//        self.url = url
//        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
//    }
//
//    var body: some View {
//        WebImage(url: url)
//            .placeholder {
//                Color.gray.opacity(0.3)
//            }
//            .resizable()
//            .scaledToFit()
//    }
//}
