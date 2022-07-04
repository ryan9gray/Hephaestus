

import UIKit

public struct Queue<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        guard !array.isEmpty, let _ = array.first else { return nil }
        return array.removeFirst()
    }
    
    public var front: T? {
        return array.first
    }
}
