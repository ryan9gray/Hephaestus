import Foundation

open class AppCacher {
    static var mappable: MappableCacherType {
        return SqliteCacher.common
    }
    static var expirable: ExpirableCacherType {
        return SqliteCacher.common
    }
    static func clearAll() {
        mappable.clearAllMappable()
        expirable.clearAllExpirable()
    }
}

public struct CacheExpiration {
    public static let week        = TimeInterval(60 * 60 * 24 * 7)
    public static let day         = TimeInterval(60 * 60 * 24)
    public static let hour        = TimeInterval(60 * 60)
    public static let halfAnHour  = TimeInterval(60 * 30)
    public static let fiveMinutes = TimeInterval(60 * 5)
}
public protocol Cacheable {
    var uniqueCacheIdentifier: String { get }
}
