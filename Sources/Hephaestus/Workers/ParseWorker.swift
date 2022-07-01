
import Foundation

struct ParseWorker {
    
    static func parse<T: Encodable>(_ object: T) -> String? {
        guard let data = try? JSONEncoder().encode(object) else { return nil }
        
        let string = String(decoding: data, as: UTF8.self)
        return string
    }
    
    static func parse<T: Decodable>(_ string: String) -> T? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let object: T? = data.decode()
        return object
    }
 }
