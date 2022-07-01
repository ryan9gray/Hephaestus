import UIKit

// swiftlint:disable class_delegate_protocol
// swiftlint:disable weak_delegate

// MARK: - CollectionViewCellSizer

public protocol CollectionViewCellSizer {
    init(collectionView: CollectionView)

    var contentSizeCategory: UIContentSizeCategory { get set }
    var cellWidthDelegate: CollectionViewCellWidthDelegate? { get set }

    func sizeForItem(at indexPath: IndexPath) -> CGSize
    func clearCache()
}

// MARK: - CollectionViewCellWidthDelegate

public protocol CollectionViewCellWidthDelegate {
    func widthForItem(at indexPath: IndexPath) -> CGFloat
}

// MARK: - CollectionViewCellAutoSizer

public class CollectionViewCellAutoSizer: CollectionViewCellSizer {
    // MARK: - Public properties

    public var contentSizeCategory: UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory
    public var cellWidthDelegate: CollectionViewCellWidthDelegate?

    // MARK: - Private properties

    private weak var collectionView: CollectionView?
    private var heightCache: [UIContentSizeCategory: [IndexPath: CGFloat]] = [:]

    // MARK: - Init

    required public init(collectionView: CollectionView) {
        self.collectionView = collectionView
    }

    // MARK: Size for item

    public func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let cachedHeight = heightCache[contentSizeCategory]?[indexPath]
        let availableWidth = widthForItem(at: indexPath)
        if let height = cachedHeight, height != 0 {
            return CGSize(width: availableWidth, height: height)
        }

        guard
            let collectionView = collectionView,
            let item = collectionView.item(at: indexPath),
            let cell = item.viewType.init() as? UICollectionViewCell
        else { return .zero }

        item.configure(view: cell)

        cell.contentView.layoutIfNeeded()
        let targetSize = CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height)
        let height = cell.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if heightCache[contentSizeCategory] == nil {
            heightCache[contentSizeCategory] = [:]
        }
        heightCache[contentSizeCategory]?[indexPath] = height

        return CGSize(width: availableWidth, height: height)
    }

    // MARK: - Clear cache

    public func clearCache() {
        heightCache.removeAll()
    }

    private func widthForItem(at indexPath: IndexPath) -> CGFloat {
        cellWidthDelegate?.widthForItem(at: indexPath) ?? (collectionView?.frame.width ?? 0)
    }
}
