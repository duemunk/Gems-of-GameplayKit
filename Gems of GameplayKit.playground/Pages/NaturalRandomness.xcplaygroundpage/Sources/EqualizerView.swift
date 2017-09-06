import UIKit

public class EqualizerView: UIView {

    public var bandValues: [CGFloat] = [1, 0.5, 1, 0.3, 1] {
        didSet {
            update()
        }
    }

    public var stroke: UIColor?
    public var fill: UIColor?
    public var background: UIColor?

    private let shapeLayer: CAShapeLayer = {
        let layer = AnimatingPathShapeLayer()
        layer.lineWidth = 2
        return layer
    }()

    public init() {
        super.init(frame: .zero)
        setup()
    }
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError() }

    public override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        update()
    }

    private func setup() {
        layer.addSublayer(shapeLayer)
        backgroundColor = .white
    }

    private func update() {
        // Paths
        let bandCount = bandValues.count
        let bandWidth = shapeLayer.bounds.width / CGFloat(bandCount)
        let bandHeight = shapeLayer.bounds.height
        var paths: [UIBezierPath] = []
        for (index, bandValue) in bandValues.enumerated() {
            let height = bandHeight * bandValue
            let rect = CGRect(
                x: CGFloat(index) * bandWidth,
                y: bandHeight - height,
                width: bandWidth,
                height: height
                ).insetBy(dx: 5, dy: 5)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 2)
            paths.append(path)
        }
        let combinedPath = UIBezierPath()
        for path in paths {
            combinedPath.append(path)
        }
        shapeLayer.path = combinedPath.cgPath
        // Colors
        shapeLayer.backgroundColor = background?.cgColor
        shapeLayer.strokeColor = stroke?.cgColor
        shapeLayer.fillColor = fill?.cgColor
    }


}
