import UIKit

public class StacksViewController: UIViewController {

    public var views: [[UIView]] = [] {
        didSet {
            updateToViews()
        }
    }

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    public convenience init(views: [[UIView]]) {
        self.init(nibName: nil, bundle: nil)
        self.views = views
        updateToViews()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        view.backgroundColor = .black
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
    }

    private func updateToViews() {
        let stackViews = views.map { (views: [UIView]) -> UIView in
            let stack = UIStackView(arrangedSubviews: views)
            stack.distribution = .fillEqually
            stack.axis = .horizontal
            return stack
        }
        set(views: stackViews, stackView: stackView)
    }

    private func set(views: [UIView], stackView: UIStackView) {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for view in views {
            stackView.addArrangedSubview(view)
        }
    }
}
