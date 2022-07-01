
import Foundation

protocol Cacheable {
    var uniqueCacheIdentifier: String { get }
}

open class CachableRequestable: NetworkRequest, Cacheable {
    static func removeCache() {
        AppCacher.expirable.removeValues(forCategory: String(describing: self))
    }
    var expirationInterval: TimeInterval {
        CacheExpiration.hour
    }
    func saveJsonToCache(fullJson: String) {
        AppCacher.expirable.saveValue(
            forId: uniqueCacheIdentifier,
            value: fullJson.description,
            expiration: Date(timeIntervalSinceNow: expirationInterval),
            category: String(describing: type(of: self))
        )
    }
    
    func getJoinedDictionaryString(parameters: [String: Any]) -> String {
        var parametersString: String = ""
        for (key, value) in parameters {
            var valueString: String? = nil
            if let value = value as? String {
                valueString = key + value
            } else if let value = value as? Int {
                valueString = key + String(value)
            } else if let value = value as? [String] {
                valueString = value.compactMap({ $0 }).joined()
            } else if let value = value as? Bool {
                valueString = key + (value ? "true" : "false")
            }

            if let valueString = valueString {
                parametersString += valueString
            }
        }
        return parametersString
    }

    var uniqueCacheIdentifier: String {
        guard
            let data = body,
            let params = data.toDictionary()
        else { return "" }
        
        var parametersString: String = fullRequestString
        
        parametersString += getJoinedDictionaryString(parameters: params)
        
        for (_, value) in params {
            var valueString: String? = nil
            if let value = value as? [String: Any] {
                valueString = getJoinedDictionaryString(parameters: value)
            } else if let value = value as? [[String: Any]] {
                var dictsString = ""
                value.forEach({ dict in
                    dictsString += getJoinedDictionaryString(parameters: dict)
                })
                if !dictsString.isEmpty {
                    valueString = dictsString
                }
            }

            if let valueString = valueString {
                parametersString += valueString
            }
        }
        if !params.isEmpty {
            return fullRequestString + "." + parametersString.md5()
        }

        return fullRequestString
    }
}
