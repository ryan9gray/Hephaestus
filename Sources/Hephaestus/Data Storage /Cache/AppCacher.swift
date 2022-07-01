import Foundation

class AppCacher {
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
struct CacheExpiration {
    static let week        = TimeInterval(60 * 60 * 24 * 7)
    static let day         = TimeInterval(60 * 60 * 24)
    static let hour        = TimeInterval(60 * 60)
    static let halfAnHour  = TimeInterval(60 * 30)
    static let fiveMinutes = TimeInterval(60 * 5)
}
