//: [Previous](@previous)
//#-hidden-code
import UIKit
import PlaygroundSupport
import GameplayKit

let stacksViewController = StacksViewController()
Playground.present(viewController: stacksViewController)

extension Array {
    func copy() -> [Element] {
        let original = self as [Any]
        let copy = NSArray(array: original, copyItems: true)
        return copy as! [Element]
    }
}
//#-end-hidden-code

func orderedViews(count: Int = 10, includeText: Bool = true) -> [UIView] {
    return (0..<count).map {
        let label = UILabel()
        let ratio = CGFloat($0) / CGFloat(count) * 0.8 + 0.2
        label.backgroundColor = UIColor(red: ratio, green: 0, blue: 0.4 * ratio, alpha: 1)
        if includeText {
            label.textColor = .primary
            label.text = "\($0)"
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 40)
        }
        label.tag
        return label
    }
}




/*:
 ---
 # Stackoverflow
 */

extension MutableCollection {
    /// Vanilla without even a GameplayKit random source
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }

    /// Shuffles the contents of this collection.
    mutating func shuffle(source: GKRandomSource = GKRandomSource.sharedRandom()) {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let max = unshuffledCount
            let d: IndexDistance = numericCast(source.nextInt(upperBound: numericCast(max)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled(source: GKRandomSource = .sharedRandom()) -> [Element] {
        var result = Array(self)
        result.shuffle(source: source)
        return result
    }
}

/*:
 ---
 # GameplayKit
 */

extension Array {
    /// Returns an array with the contents of this sequence, shuffled.
    func betterShuffled(source: GKRandomSource = .sharedRandom()) -> [Element] {
//        return (self as NSArray).shuffled(using: source) as! [Element]
        return source.arrayByShufflingObjects(in: self) as! [Element]
    }
}

/*:
 ---
 */


func createSource(seed: Int) -> GKRandomSource {
    return GKARC4RandomSource(seed: "\(seed)".data(using: .utf8)!)
}

([1, 2, 3] as NSArray).shuffled()


let seed = 2
let count = 6
stacksViewController.views = [
    orderedViews(count: count),
    orderedViews(count: count).shuffled(source: createSource(seed: seed)),
    orderedViews(count: count).betterShuffled(source: createSource(seed: seed)),

    /* Other distributions */

//    orderedViews().betterShuffled(source: GKMersenneTwisterRandomSource(seed: numericCast(seed))),
//    orderedViews().betterShuffled(source: GKLinearCongruentialRandomSource(seed: numericCast(seed)))
]




/* Screenshots for talk */
do {
    let seed = 2
    let count = 10
    let size = CGSize(width: 800, height: 600)
    StacksViewController(views: [
        orderedViews(count: count, includeText: false),
        orderedViews(includeText: false).shuffled(source: createSource(seed: seed)),
        orderedViews(count: count, includeText: false).betterShuffled(source: createSource(seed: seed)),
    ]).save(filename: "ShuffledArraysEmpty", size: size)

    StacksViewController(views: [
        orderedViews(count: count, includeText: true),
        orderedViews(includeText: true).shuffled(source: createSource(seed: seed)),
        orderedViews(count: count, includeText: true).betterShuffled(source: createSource(seed: seed)),
    ]).save(filename: "ShuffledArrays", size: size)
}


//: [Next](@next)
