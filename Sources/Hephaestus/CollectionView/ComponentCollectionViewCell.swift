import UIKit

// swiftlint:disable line_length

public class ComponentCollectionViewCell<ViewType: CellContentViewProtocol>: UICollectionViewCell, CellContentViewProtocol where ViewType: UIView {
    // swiftlint:enable line_length
    // MARK: - Properties

    private(set) public lazy var containerView = ViewType()

    public override var isSelected: Bool {
        didSet {
            containerView.isSelected = isSelected
        }
    }

    public var model: ViewType.DataType! {
        didSet {
            containerView.model = model
        }
    }

    // MARK: - Initialization

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(containerView.prepareForAutoLayout())
        containerView.pinEdgesToSuperviewEdges()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Size

    public override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let size = containerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: size.width, height: max(size.height, containerView.intrinsicContentSize.height))
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

    }

}
