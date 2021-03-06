import Foundation

protocol CacherType {
    func clearAllCache()
}

protocol MappableCacherType: CacherType {
    func saveObject<T: Codable>(_ object: T)
    func getObject<T: Codable>(of type: T.Type) -> T?
    func saveObject<T: Codable>(_ object: T, withId identifier: String)
    func getObject<T: Codable>(of type: T.Type, withId identifier: String) -> T?
    func saveArray<T: Codable>(_ array: [T])
    func getArray<T: Codable>(of type: T.Type) -> (array: [T], needReload: Bool)
    func saveArray<T: Codable>(_ array: [T],withId identifier: String)
    func getArray<T: Codable>(of type: T.Type, withId identifier: String?) -> (array: [T], needReload: Bool)
    func removeValue<T: Codable>(of type: T.Type)
    func removeValue(forIdentifier identifier: String)
    func clearAllMappable()
    func cacheExpired<T: Codable>(for type: T.Type) -> Bool
}

protocol ExpirableCacherType: CacherType {
    func saveValue(forId identifier: String, value: String, expiration: Date)
    func saveValue(forId identifier: String, value: String, expiration: Date, category: String?)
    func getValue(forId identifier: String) -> String?
    func getValue(forId identifier: String, shoudDelete: Bool) -> String?
    func getForceValue(forId identifier: String) -> String?
    func removeValue(forId identifier: String)
    func removeValues(forCategory category: String?)
    func clearAllExpirable()
}
