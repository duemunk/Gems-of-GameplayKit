import UIKit

class AnimatingPathShapeLayer: CAShapeLayer {

    override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(path) {
            let animation = CABasicAnimation(keyPath: event)
//            animation.duration = UIView.inheritedAnimationDuration
            animation.duration = CATransaction.animationDuration()
            animation.timingFunction = CATransaction.animationTimingFunction()
            return animation
        }
        return super.action(forKey: event)
    }
}
