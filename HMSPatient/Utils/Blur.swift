import SwiftUI

class UIBackdropView: UIView {
    override class var layerClass: AnyClass {
        NSClassFromString("CABackdropLayer") ?? CALayer.self
    }
}

struct Backdrop: UIViewRepresentable {
    func makeUIView(context: Context) -> UIBackdropView {
        UIBackdropView()
    }
    
    func updateUIView(_ uiView: UIBackdropView, context: Context) {}
}

struct Blur: View {
    var radius: CGFloat = 7
    var opaque: Bool = false
    var tintColor: Color = Color("BlurColor")
    var tintOpacity: Double = 0.5 // Adjust this value to control the intensity of the whitish tint
    
    var body: some View {
        ZStack {
            Backdrop()
                .blur(radius: radius, opaque: opaque)
            
            tintColor.opacity(tintOpacity)
        }
    }
}

struct Blur_Previews: PreviewProvider {
    static var previews: some View {
        Blur()
    }
}
