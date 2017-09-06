import UIKit

public class StackViewController: UIViewController {

    public var views: [UIView] = [] {
        didSet {
            set(views: views, stackView: stackView)
        }
    }

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()


    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
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

