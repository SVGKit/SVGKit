
import SwiftUI
import SVGKit

#if canImport(AppKit)
import AppKit

@available(macOS 10.15, *)
struct SVGKFastImageViewSUI: NSViewRepresentable {
    @Binding var url: URL
    @Binding var iconSize: CGFloat

    func makeNSView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(contentsOf: url)
        return SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
    }

    func updateNSView(_ nsView: SVGKFastImageView, context: Context) {
        // TODO: SVGKImage(contentsOf:) can return nil; assigning nil to nsView.image will crash
        nsView.image = SVGKImage(contentsOf: url)
        nsView.image.size = CGSize(width: iconSize, height: iconSize)
    }
}

@available(macOS 10.15, *)
struct SVGImage_Previews: PreviewProvider {
    static var previews: some View {
        SVGKFastImageViewSUI(
            url: .constant(URL(string: "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg")!),
            iconSize: .constant(50.0)
        )
    }
}

#else
import UIKit

@available(iOS 13.0, tvOS 13.0, visionOS 1.0, *)
struct SVGKFastImageViewSUI: UIViewRepresentable {
    @Binding var url: URL
    @Binding var iconSize: CGFloat

    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(contentsOf: url)
        return SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
    }

    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        // TODO: SVGKImage(contentsOf:) can return nil; assigning nil to uiView.image will crash
        uiView.image = SVGKImage(contentsOf: url)
        uiView.image.size = CGSize(width: iconSize, height: iconSize)
    }
}

@available(iOS 13.0, tvOS 13.0, visionOS 1.0, *)
struct SVGImage_Previews: PreviewProvider {
    static var previews: some View {
        SVGKFastImageViewSUI(
            url: .constant(URL(string: "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg")!),
            iconSize: .constant(50.0)
        )
    }
}
#endif
