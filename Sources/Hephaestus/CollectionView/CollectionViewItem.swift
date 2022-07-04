import UIKit

public class CollectionViewItem<
    ViewType: CellContentViewProtocol,
    DataType: CellContentViewModelProtocol
>: CollectionViewItemProtocol where ViewType.DataType == DataType, ViewType: UIView {
    // MARK: - Properties

    public static var cellReuseIdentifier: String { return String(describing: ViewType.self) }
    public var viewType: UIView.Type { ViewType.self }

    public var diff: CollectionViewItemDiffable {
        guard let model = model as? IdentifiableProtocol,
              model.id != "" else { return .zero }
        return .init(id: model.id, snapshot: model.snapshot)
    }

    public let model: DataType

    // MARK: - Initialization

    public init(_ model: DataType) {
        self.model = model
    }

    // MARK: - Configure

    public func configure(view: UIView) {
        guard var view = (view as? ViewType) else { return }
        view.model = model
    }
}
