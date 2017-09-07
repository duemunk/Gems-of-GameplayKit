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









let viewController = RubberbandViewController()
Playground.present(viewController: viewController)

var points: [Point] = []

let count = 1000
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.2, y: 0.3), deviation: 0.3, color: .accent))
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.8, y: 0.5), deviation: 0.3, color: .primary))
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.3, y: 0.7), deviation: 0.3, color: .secondary))

viewController.points = points



//: [Next](@next)
