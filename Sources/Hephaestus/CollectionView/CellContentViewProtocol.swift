import Foundation

public protocol CellContentViewProtocol {
    associatedtype DataType
    var isSelected: Bool { get set }
    var model: DataType! { get set }
}
