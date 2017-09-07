import UIKit

public class SquareShapeLayer: CAShapeLayer {
    public var normalizedRect: CGRect? = nil { didSet { setNeedsLayout() } }

    public override func setNeedsLayout() {
        super.setNeedsLayout()

        guard let normalizedRect = normalizedRect else {
            self.path = nil
            return
        }
        let rect = CGRect(
            x: normalizedRect.origin.x * bounds.width,
            y: normalizedRect.origin.y * bounds.height,
            width: normalizedRect.width * bounds.width,
            height: normalizedRect.height * bounds.height
        )
        self.path = CGPath(roundedRect: rect, cornerWidth: 0, cornerHeight: 0, transform: nil)
    }
}
