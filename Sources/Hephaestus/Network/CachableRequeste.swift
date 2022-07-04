
import Foundation

open class CachableRequeste: NetworkRequest, Cacheable {
    var expirationInterval: TimeInterval

    public init(
        endpoint: Endpoint,
        httpMethod: HTTPMethod,
        expirationInterval: TimeInterval,
        body: Data?
    ) {
        self.expirationInterval = expirationInterval
        super.init(endpoint: endpoint, httpMethod: httpMethod, body: body)
    }

    func removeCache() {
       // AppCacher.expirable.removeValues(forCategory: String(describing: self))
        AppCacher.expirable.removeValue(forId: uniqueCacheIdentifier)
    }
    func saveJsonToCache(fullJson: String) {
        AppCacher.expirable.saveValue(
            forId: uniqueCacheIdentifier,
            value: fullJson.description,
            expiration: Date(timeIntervalSinceNow: expirationInterval),
            category: String(describing: type(of: self))
        )
    }
    
    func cachedResponse<T: Codable>() -> T? {
        if
            let jsonString = AppCacher.expirable.getValue(forId: uniqueCacheIdentifier, shoudDelete: true),
            let data = jsonString.data(using: .utf8)
        {
            return try? JSONDecoder().decode(T.self, from: data)
        } else {
            removeCache()
            return nil
        }
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

    public var uniqueCacheIdentifier: String {
        guard
            let params = body?.dictionary
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
