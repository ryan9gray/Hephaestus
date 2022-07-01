import UIKit

open class CollectionView: UICollectionView,
                           UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Initialization

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupViews()
    }

    public init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        dataSource = self
        delegate = self
    }

    // MARK: - Update

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard previousTraitCollection != nil,
              previousTraitCollection?.preferredContentSizeCategory !=
                traitCollection.preferredContentSizeCategory else {
            return
        }

        if isCellSizerUsed {
            cellSizer.clearCache()
        }

        if isHeaderAndFooterSizerUsed {
            headerAndFooterSizer.removeCache()
        }

        if isCellSizerUsed || isHeaderAndFooterSizerUsed {
            collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Sizers

    public lazy var cellSizer: CollectionViewCellSizer = {
        isCellSizerUsed = true
        return CollectionViewCellAutoSizer(collectionView: self)
    }()

    public lazy var headerAndFooterSizer: CollectionViewHeaderAndFooterSizer = {
        isHeaderAndFooterSizerUsed = true
        return CollectionViewHeaderAndFooterSizer()
    }()

    private var isCellSizerUsed = false
    private var isHeaderAndFooterSizerUsed = false

    // MARK: - Properties

    public var sections: [CollectionViewSection] = [] {
        didSet {
            reloadData()
        }
    }

    // MARK: - Register

    public func registerCells(_ items: [UICollectionViewCell.Type]) {
        for value in items {
            register(value, forCellWithReuseIdentifier: String(describing: value))
        }
    }

    // MARK: - UICollectionViewDataSource

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = item(at: indexPath) else { fatalError("fatalError: cellForItemAt indexPath") }
        let cellReuseIdentifier = type(of: item).cellReuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        item.configure(view: cell)
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    // MARK: - Item At IndexPath

    public func item(at indexPath: IndexPath) -> CollectionViewItemProtocol? {
        let section = sections[indexPath.section]
        return (section.items.count > indexPath.row) ? section.items[indexPath.row] : nil
    }
}
