import UIKit

public struct Point {
    public let normalizedCenter: CGPoint
    public let color: UIColor
    public let selected: Bool

    public init(normalizedCenter: CGPoint, color: UIColor, selected: Bool = false) {
        self.normalizedCenter = normalizedCenter
        self.color = color
        self.selected = selected
    }
}

extension Point: Equatable {
    public static func == (_ lhs: Point, _ rhs: Point) -> Bool {
        return lhs.normalizedCenter == rhs.normalizedCenter
    }
}
