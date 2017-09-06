import UIKit

public extension UIView {

    public var snapshot: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

public extension UIViewController {
    public var snapshot: UIImage {
        return view.snapshot
    }
}
