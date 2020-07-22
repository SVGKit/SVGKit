
import SwiftUI
import SVGKit

@available(iOS 13.0, tvOS 13.0, *)
struct SVGKFastImageViewSUI:UIViewRepresentable
{
    @Binding var url:URL
    @Binding var iconSize:CGFloat
    
    func makeUIView(context: Context) -> SVGKFastImageView {

        let svgImage = SVGKImage(contentsOf: url)
        return SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
        
    }
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        uiView.image = SVGKImage(contentsOf: url)
        
        uiView.image.size = CGSize(width: iconSize,height: iconSize)
    }
    
    
}

@available(iOS 13.0, tvOS 13.0, *)
struct SVGImage_Previews: PreviewProvider {
    static var previews: some View {
        SVGKFastImageViewSUI(url: .constant(URL(string:"https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg")!), iconSize: .constant(50.0))
    }
}
