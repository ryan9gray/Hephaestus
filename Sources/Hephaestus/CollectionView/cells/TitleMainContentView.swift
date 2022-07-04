
import UIKit

public class TitleMainContentView: UIView, CellContentViewProtocol {

    public struct Model: CellContentViewModelProtocol, IdentifiableProtocol {
        public var callbackAction: ((Model) -> ())?
        public var isSelected: Bool = false {
            didSet {
                callbackAction?(self)
            }
        }
        public let title: String

        public var id: String {
            return title
        }
        public init(title: String) {
            self.title = title
        }
    }

    public var isSelected: Bool = false

    public var model: Model! {
        didSet {
            titleMainView.text = model.title
        }
    }

    private lazy var titleMainView = UILabel()

    // MARK: - Lifecycle
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init() {
        super.init(frame: .zero)
        titleMainView.numberOfLines = 10
        titleMainView.textAlignment = .center
        setupLayout()
    }
    func setupLayout() {
        addSubview(titleMainView.prepareForAutoLayout())
        titleMainView.pinEdgesToSuperviewEdges()
    }
}
