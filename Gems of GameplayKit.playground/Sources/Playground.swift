import PlaygroundSupport
import UIKit

public class Playground {
    public static func present(viewController: UIViewController, size: CGSize = CGSize(width: 400, height: 300)) {
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        PlaygroundPage.current.liveView = window
    }
}

extension UIView {
    public func save(filename: String, size: CGSize? = nil) {
        if let size = size {
            frame.size = size
        }
        let data = UIImagePNGRepresentation(snapshot)
        let url = playgroundSharedDataDirectory.appendingPathComponent(filename + ".png")
        do {
            try data?.write(to: url)
            print("Saved to", url)
        } catch {
            print("Failed to save to file", filename, error)
        }
    }
}

extension UIViewController {
    public func save(filename: String, size: CGSize? = nil) {
        if let size = size {
            view.frame.size = size
        }
        let data = UIImagePNGRepresentation(snapshot)
        let url = playgroundSharedDataDirectory.appendingPathComponent(filename + ".png")
        do {
            try data?.write(to: url)
            print("Saved to", url)
        } catch {
            print("Failed to save to file", filename, error)
        }
    }
}

