import Foundation

open class CollectionViewSection {
    // MARK: - Properties

    open private(set) var items: [CollectionViewItemProtocol]
    public let title: String?
    public var isCollapsed: Bool

    // MARK: - Initialization

    public init(
        title: String? = nil,
        items: [CollectionViewItemProtocol] = [],
        isCollapsed: Bool = false
    ) {
        self.items = items
        self.title = title
        self.isCollapsed = isCollapsed
    }

    // MARK: - Actions

    public func append(contentsOf newElements: [CollectionViewItemProtocol]) {
        items.append(contentsOf: newElements)
    }

    public func insert(_ newElement: CollectionViewItemProtocol, at index: Int) {
        items.insert(newElement, at: index)
    }

    public func remove(at index: Int) -> CollectionViewItemProtocol {
        return items.remove(at: index)
    }

    public func append(_ newElement: CollectionViewItemProtocol) {
        items.append(newElement)
    }
}
