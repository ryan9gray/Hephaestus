import UIKit

// swiftlint:disable identifier_name

public struct CollectionViewItemDiffable: Equatable {
    static let zero = CollectionViewItemDiffable(id: "", snapshot: "")
    let id: String
    let snapshot: String
}

public protocol CollectionViewItemProtocol {
    static var cellReuseIdentifier: String { get }
    var viewType: UIView.Type { get }
    var diff: CollectionViewItemDiffable { get }
    func configure(view: UIView)
}
