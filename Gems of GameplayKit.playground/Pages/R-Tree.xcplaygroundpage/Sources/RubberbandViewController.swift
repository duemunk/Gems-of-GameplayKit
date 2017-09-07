import UIKit
import GameplayKit

public class RubberbandViewController: UIViewController {

    public var points: [Point] = [] {
        didSet {
            updateTree()
            updateUI()
        }
    }
    private let pointCloud = PointLayer()
    private var tree: GKRTree<Point>? = nil
//    private var tree: GKQuadtree<Point>? = nil
    private let rubberBandLayer: SquareShapeLayer = {
        let layer = SquareShapeLayer()
        layer.strokeColor = UIColor.cyan.cgColor
        layer.lineWidth = 2
        layer.fillColor = nil
        return layer
    }()
    private var normalizedRubberBand: CGRect? = CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.4) {
        didSet {
            updateUI()
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

    private func updateTree() {
        let tree = GKRTree<Point>(maxNumberOfChildren: 100)
        for point in points {
            let center = point.normalizedCenter.vector_float2
            tree.addElement(point, boundingRectMin: center, boundingRectMax: center, splitStrategy: .reduceOverlap)
        }
        self.tree = tree

//        let tree = GKQuadtree<Point>(boundingQuad: GKQuad(quadMin: vector2(0, 0), quadMax: vector2(1, 1)), minimumCellSize: 0.1)
//        for point in points {
//            let center = point.normalizedCenter.vector_float2
//            tree.add(point, at: center)
//        }
//        self.tree = tree
    }

    private func updateUI() {
        rubberBandLayer.normalizedRect = normalizedRubberBand
        if let normalizedRubberBand = normalizedRubberBand {
            let start = Date()
            print("—")
            DispatchQueue.global(qos: .background).async {
                let pointsInsideRubberBand = self.usingTree_points(self.points, inRect: normalizedRubberBand)
                print("Tree:", -start.timeIntervalSinceNow)
                DispatchQueue.main.async {
                    self.pointCloud.points = self.selectPoints(self.points, inPoints: pointsInsideRubberBand)
                }
            }
            DispatchQueue.global(qos: .background).async {
                let _ = self.naïve_points(self.points, inRect: normalizedRubberBand)
                print("Naïve:", -start.timeIntervalSinceNow)
            }
        } else {
            pointCloud.points = points
        }
    }

    private func usingTree_points(_ points: [Point], inRect: CGRect) -> [Point] {
        let min = inRect.min
        let max = inRect.max
        let inRubberBand = tree?.elements(inBoundingRectMin: min.vector_float2, rectMax: max.vector_float2) ?? []
//        let testQuad = GKQuad(quadMin: min.vector_float2, quadMax: max.vector_float2)
//        let inRubberBand = tree?.elements(in: testQuad) ?? []
        return inRubberBand
    }

    private func naïve_points(_ points: [Point], inRect: CGRect) -> [Point] {
        return points.filter { point in
            return inRect.contains(point.normalizedCenter)
        }
    }

    private func selectPoints(_ points: [Point], inPoints: [Point]) -> [Point] {

        let newPoints = points.map { (point: Point) -> Point in
            if inPoints.contains(point) {
                return Point(normalizedCenter: point.normalizedCenter, color: point.color, selected: true)
            } else {
                return point
            }
        }
        return newPoints
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

