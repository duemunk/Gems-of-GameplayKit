import UIKit

public class Point: NSObject {
    public let normalizedCenter: CGPoint
    public let color: UIColor
    public let selected: Bool

    public init(normalizedCenter: CGPoint, color: UIColor, selected: Bool = false) {
        self.normalizedCenter = normalizedCenter
        self.color = color
        self.selected = selected
    }
}
