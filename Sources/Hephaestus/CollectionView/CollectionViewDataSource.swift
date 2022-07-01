import Foundation
import UIKit

open class CollectionViewDataSource: NSObject, UICollectionViewDataSource,
                                     UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    open private(set) var sections: [CollectionViewSection] = []
    public let collectionView: UICollectionView

    // MARK: - Initialization

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    // MARK: - Register

    open func register(cells: [UICollectionViewCell.Type]) {
        cells.forEach({ collectionView.register($0, forCellWithReuseIdentifier: String(describing: $0)) })
    }

    // MARK: - Set

    open func set(sections new: [CollectionViewSection], diffable: Bool = false) {
        collectionView.performBatchUpdates(old: sections, new: new, diffable: diffable, updates: { [weak self] in
            self?.sections = new
        })
    }

    // MARK: - UICollectionViewDataSource

    open func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        let item = sections[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        sections[destinationIndexPath.section].insert(item, at: destinationIndexPath.row)
    }

    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
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

    open func item(at indexPath: IndexPath) -> CollectionViewItemProtocol? {
        let section = sections[indexPath.section]
        return (section.items.count > indexPath.row) ? section.items[indexPath.row] : nil
    }
}
