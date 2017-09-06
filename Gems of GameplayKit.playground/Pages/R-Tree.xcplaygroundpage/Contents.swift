//: [Previous](@previous)

import UIKit
import GameplayKit
import PlaygroundSupport

//class Point: NSObject {
//    var x: Float = 0
//    var y: Float = 0
//    var name: String = "?"
//    var padding: Float = 0.05
//
//    init(x: Float, y: Float, name: String) {
//        self.x = x
//        self.y = y
//        self.name = name
//    }
//    override var description: String {
//        return String(format: "%@ (%f,%f) ±%f", name, x, y, padding)
//    }
//    
//    var v2: vector_float2 {
//        return vector2(Float(x), Float(y))
//    }
//
//    var v2min: vector_float2 {
//        return vector2(Float(x - padding), Float(y - padding))
//    }
//
//    var v2max: vector_float2 {
//        return vector2(Float(x + padding), Float(y + padding))
//    }
//}
//
//do {
//    let tree = GKRTree<Point>(maxNumberOfChildren: 4)
//
//    func add(point: Point, to tree: GKRTree<Point>) {
//        tree.addElement(point, boundingRectMin: point.v2min, boundingRectMax: point.v2max, splitStrategy: .linear)
//    }
//
//    let a = Point(x: 0, y: 0, name: "a")
//    let b = Point(x: 0, y: 1, name: "b")
//    let c = Point(x: 2, y: 2, name: "c")
//    let d = Point(x: 0.1, y: 0.1, name: "d")
//
//    for point in [a, b, c, d] {
//        add(point: point, to: tree)
//    }
//
//    for point in tree.elements(inBoundingRectMin: vector2(0, 0), rectMax: vector2(1, 1)) {
////        print(point)
//    }
//}
//
//do {
//    let quad = GKQuad(quadMin: vector2(0, 0), quadMax: vector2(1, 1))
//    let tree = GKQuadtree<Point>(boundingQuad: quad, minimumCellSize: 0.1)
//
//    let a = Point(x: 0, y: 0, name: "a")
//    let b = Point(x: 0, y: 0.5, name: "b")
//    let c = Point(x: 1, y: 1, name: "c")
//    let d = Point(x: 0.1, y: 0.1, name: "d")
//
//    func add(point: Point, to tree: GKQuadtree<Point>) {
//        tree.add(point, at: point.v2)
//    }
//
//    for point in [a, b, c, d] {
//        add(point: point, to: tree)
//    }
//
//    let testQuad = GKQuad(quadMin: vector2(0, 0), quadMax: vector2(0.5, 0.6))
//    for point in tree.elements(in: testQuad) {
//        print(point)
//    }
//}





struct Point {
    let normalizedCenter: CGPoint
    let color: UIColor
    let selected: Bool

    init(normalizedCenter: CGPoint, color: UIColor, selected: Bool = false) {
        self.normalizedCenter = normalizedCenter
        self.color = color
        self.selected = selected
    }
}

extension Point: Equatable {
    static func == (_ lhs: Point, _ rhs: Point) -> Bool {
        return lhs.normalizedCenter == rhs.normalizedCenter
    }
}

class Box<T>: NSObject {
    let content: T

    init(content: T) {
        self.content = content
    }
}

class PointCloud: CALayer {

    var points: [Point] = [] { didSet { setNeedsDisplay() } }

    override func draw(in ctx: CGContext) {
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

class SquareShapeLayer: CAShapeLayer {
    var normalizedRect: CGRect? = nil { didSet { setNeedsLayout() } }

    override func setNeedsLayout() {
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
        self.path = CGPath.init(roundedRect: rect, cornerWidth: 0, cornerHeight: 0, transform: nil)
    }
}

extension CGPoint {
    var vector_float2: vector_float2 { return simd.vector_float2(x: Float(x), y: Float(y)) }
}

extension CGRect {
    var min: CGPoint { return CGPoint(x: minX, y: minY) }
    var max: CGPoint { return CGPoint(x: maxX, y: maxY) }
    func normalize(point: CGPoint) -> CGPoint {
        return CGPoint(
            x: (point.x - minX) / width,
            y: (point.y - minY) / height
        )
    }
}


class RubberbandViewController: UIViewController {

    var points: [Point] = [] {
        didSet {
            updateTree()
            updateUI()
        }
    }
    private let pointCloud = PointCloud()
//    private var tree: GKRTree<Box<Point>>? = nil
    private var tree: GKQuadtree<Box<Point>>? = nil
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(pointCloud)
        view.layer.addSublayer(rubberBandLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pointCloud.frame = view.layer.bounds
        rubberBandLayer.frame = view.layer.bounds
    }

    private func updateTree() {
//        let tree = GKRTree<Box<Point>>(maxNumberOfChildren: 100)
//        for point in points {
//            let center = point.normalizedCenter.vector_float2
//            let box = Box(content: point)
//            tree.addElement(box, boundingRectMin: center, boundingRectMax: center, splitStrategy: .reduceOverlap)
//        }
//        self.tree = tree

        let tree = GKQuadtree<Box<Point>>(boundingQuad: GKQuad(quadMin: vector2(0, 0), quadMax: vector2(1, 1)), minimumCellSize: 0.1)
        for point in points {
            let center = point.normalizedCenter.vector_float2
            let box = Box(content: point)
            tree.add(box, at: point.normalizedCenter.vector_float2)
        }
        self.tree = tree
    }

    private func updateUI() {
        rubberBandLayer.normalizedRect = normalizedRubberBand
        if let normalizedRubberBand = normalizedRubberBand {
            let start = Date()
            DispatchQueue.global(qos: .background).async {
                let pointsInsideRubberBand = self.usingTree_points(self.points, inRect: normalizedRubberBand)
                print("Tree:", -start.timeIntervalSinceNow)
                DispatchQueue.main.async {
                    self.pointCloud.points = self.selectPoints(self.points, inPoints: pointsInsideRubberBand)
                }
            }
            DispatchQueue.global(qos: .background).async {
                let pointsInsideRubberBand = self.naïve_points(self.points, inRect: normalizedRubberBand)
                print("Naïve:", -start.timeIntervalSinceNow)
            }
        } else {
            pointCloud.points = points
        }
    }

    private func usingTree_points(_ points: [Point], inRect: CGRect) -> [Point] {
        let min = inRect.min
        let max = inRect.max
        //        let min = CGPoint(x: inRect.minX, y: inRect.maxY)
        //        let max = CGPoint(x: inRect.maxX, y: inRect.minY)
        //        let inRubberBand = tree?.elements(inBoundingRectMin: min.vector_float2, rectMax: max.vector_float2)
        let testQuad = GKQuad(quadMin: min.vector_float2, quadMax: max.vector_float2)
        let inRubberBand = tree?.elements(in: testQuad)
            .flatMap { $0.content }
            ?? []
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)
        let normalizedPoint = view.frame.normalize(point: point)

        normalizedRubberBand = CGRect(
            origin: normalizedPoint,
            size: .zero
        )
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
let viewController = RubberbandViewController()
PlaygroundPage.current.liveView = viewController

func createPoints(count: Int, aroundPoint: CGPoint, source: GKRandomSource = GKARC4RandomSource.sharedRandom(), deviation: Float, color: UIColor) -> [Point] {
    var points: [Point] = []
    let sourceX = GKGaussianDistribution(randomSource: source, mean: 0, deviation: 100)
    let sourceY = GKGaussianDistribution(randomSource: source, mean: 0, deviation: 100)
    for _ in 0..<count {
        let x = CGFloat(sourceX.nextUniform() * deviation) + aroundPoint.x
        let y = CGFloat(sourceY.nextUniform() * deviation) + aroundPoint.y
        let center = CGPoint(x: x, y: y)
        let point = Point(
            normalizedCenter: center,
            color: color
        )
        points.append(point)
    }
    return points
}

var points: [Point] = []

let count = 100
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.2, y: 0.3), deviation: 0.3, color: .yellow))
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.8, y: 0.5), deviation: 0.3, color: .red))
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.3, y: 0.7), deviation: 0.3, color: .blue))

viewController.points = points



//: [Next](@next)
