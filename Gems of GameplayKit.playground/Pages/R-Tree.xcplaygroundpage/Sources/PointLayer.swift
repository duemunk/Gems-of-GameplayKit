import UIKit


public class PointLayer: CALayer {

    public var points: [Point] = [] { didSet { setNeedsDisplay() } }

    public override func draw(in ctx: CGContext) {
        super.draw(in: ctx)

        for point in points {
            let center = CGPoint(
                x: point.normalizedCenter.x * bounds.width,
                y: point.normalizedCenter.y * bounds.height
            )
            let size = point.selected ? CGSize(width: 10, height: 10) : CGSize(width: 5, height: 5)
            let rect = CGRect(
                origin: CGPoint(
                    x: center.x - size.width / 2,
                    y: center.y - size.height / 2),
                size: size)
            let path = CGPath(ellipseIn: rect, transform: nil)

            ctx.addPath(path)
            ctx.setFillColor(point.color.cgColor)
            ctx.fillPath()
        }
    }
}
