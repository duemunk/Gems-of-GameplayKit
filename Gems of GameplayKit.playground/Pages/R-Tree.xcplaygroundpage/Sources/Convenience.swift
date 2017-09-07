import CoreGraphics
import GameplayKit

extension CGPoint {
    public var vector_float2: vector_float2 { return simd.vector_float2(x: Float(x), y: Float(y)) }
}

extension CGRect {
    public var min: CGPoint { return CGPoint(x: minX, y: minY) }
    public var max: CGPoint { return CGPoint(x: maxX, y: maxY) }
    public func normalize(point: CGPoint) -> CGPoint {
        return CGPoint(
            x: (point.x - minX) / width,
            y: (point.y - minY) / height
        )
    }
}

public func createPoints(count: Int, aroundPoint: CGPoint, source: GKRandomSource = GKARC4RandomSource.sharedRandom(), deviation: Float, color: UIColor) -> [Point] {
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
