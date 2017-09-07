//: [Previous](@previous)

import UIKit
import GameplayKit
import PlaygroundSupport


let viewController = RubberbandViewController()
viewController.selectionColor = .primary
viewController.backgroundColor = .background
Playground.present(viewController: viewController)


var points: [Point] = []
let count = 30
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.4, y: 0.3), deviation: 0.3, color: .accent))
points.append(contentsOf: createPoints(count: count, aroundPoint: CGPoint(x: 0.6, y: 0.7), deviation: 0.3, color: .secondary))

/*:
 ---
 # Naive
 */

private func naivePoints(inRect: CGRect) -> [Point] {
    return points.filter { point in
        return inRect.contains(point.normalizedCenter)
    }
}


/*:
 ---
 # GameplayKit
 */


let tree = GKRTree<Point>(maxNumberOfChildren: 10)
for point in points {
    let center = point.normalizedCenter.vector_float2
    tree.addElement(point, boundingRectMin: center, boundingRectMax: center, splitStrategy: .reduceOverlap)
}

private func gemPoints(tree: GKRTree<Point>, inRect: CGRect) -> [Point] {
    let rectMin = inRect.min
    let rectMax = inRect.max
    let pointsInRect = tree.elements(inBoundingRectMin: rectMin.vector_float2, rectMax: rectMax.vector_float2) ?? []
    return pointsInRect
}




viewController.points = points
viewController.didUpdateSelection = { rect in
    guard let rect = rect else { return }
    
    for point in points {
        point.selected = false
    }
    for point in gemPoints(tree: tree, inRect: rect) {
        point.selected = true
    }
    viewController.points = points
}





/* Screenshots for talk */
do {
    let count = 500
    let size = CGSize(width: 800, height: 600)
    let points = createPoints(count: count, aroundPoint: CGPoint(x: 0.5, y: 0.5), deviation: 0.4, color: .accent)

    let viewController = RubberbandViewController()
    viewController.selectionColor = .primary
    viewController.backgroundColor = .background

    viewController.points = points
    viewController.normalizedRubberBand = nil
    viewController.save(filename: "R-TreeEmpty", size: size)

    let tree = GKRTree<Point>(maxNumberOfChildren: 100)
    for point in points {
        let center = point.normalizedCenter.vector_float2
        tree.addElement(point, boundingRectMin: center, boundingRectMax: center, splitStrategy: .reduceOverlap)
    }
    let rects = [
        CGRect(x: 0.3, y: 0.3, width: 0.1, height: 0.1),
        CGRect(x: 0.3, y: 0.3, width: 0.2, height: 0.2),
        CGRect(x: 0.3, y: 0.3, width: 0.3, height: 0.3),
    ]
    for (index, rect) in rects.enumerated() {
        for point in points {
            point.selected = false
        }
        viewController.normalizedRubberBand = rect
        for point in gemPoints(tree: tree, inRect: rect) {
            point.selected = true
        }
        viewController.points = points
        viewController.save(filename: "R-Tree\(index)", size: size)
    }
}












//: [Next](@next)
