
import UIKit

final class TitleMainContentView: UIView, CellContentViewProtocol {

    struct Model: CellContentViewModelProtocol, IdentifiableProtocol {
        var callbackAction: ((Model) -> ())?
        var isSelected: Bool = false {
            didSet {
                callbackAction?(self)
            }
        }
        let title: String

        var id: String {
            return title
        }
    }

    var isSelected: Bool = false

    var model: Model! {
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

        setupLayout()
    }
    func setupLayout() {
        addSubview(titleMainView.prepareForAutoLayout())
        titleMainView.pinEdgesToSuperviewEdges()
    }
}
