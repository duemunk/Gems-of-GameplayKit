import UIKit
import GameplayKit

public class RubberbandViewController: UIViewController {

    public var didUpdateSelection: ((CGRect?) -> ())? = nil {
        didSet {
            didUpdateSelection?(normalizedRubberBand)
        }
    }

    public var points: [Point] = [] {
        didSet {
            updateUI()
        }
    }

    public var selectionColor: UIColor? = nil {
        didSet {
            rubberBandLayer.strokeColor = selectionColor?.cgColor
        }
    }
    public var backgroundColor: UIColor? = nil {
        didSet {
            pointCloud.backgroundColor = backgroundColor?.cgColor
        }
    }

    private let pointCloud: PointLayer = {
        let layer = PointLayer()
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    private let rubberBandLayer: SquareShapeLayer = {
        let layer = SquareShapeLayer()
        layer.lineWidth = 2
        layer.fillColor = nil
        return layer
    }()
    public var normalizedRubberBand: CGRect? = CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.4) {
        didSet {
            updateUI()
            didUpdateSelection?(normalizedRubberBand)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(pointCloud)
        view.layer.addSublayer(rubberBandLayer)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pointCloud.frame = view.layer.bounds
        rubberBandLayer.frame = view.layer.bounds
    }

    private func updateUI() {
        rubberBandLayer.normalizedRect = normalizedRubberBand
        pointCloud.points = points
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)
        let normalizedPoint = view.frame.normalize(point: point)

        normalizedRubberBand = CGRect(
            origin: normalizedPoint,
            size: .zero
        )
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)
        let normalizedPoint = view.frame.normalize(point: point)

        guard let normalizedRubberBand = normalizedRubberBand else { return }
        self.normalizedRubberBand?.size = CGSize(
            width: normalizedPoint.x - normalizedRubberBand.origin.x,
            height: normalizedPoint.y - normalizedRubberBand.origin.y
        )
    }
}

