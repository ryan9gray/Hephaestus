
import Foundation

public extension Dictionary {

    func retriveData() -> Result<Data, Error> {
           return Result { try JSONSerialization.data(withJSONObject: self) }
    }
    func retriveData() -> Data? {
          do {
              return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
          } catch let NetworkServiceError {
              print("\n\n\nError => getDataFromJson => \(NetworkServiceError.localizedDescription)")
          }
          return nil
      }
    
    func toJson() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }
          if let string = String(data: data, encoding: .utf8) {
              return string
          }
         return nil
      }
    func decode<T: Codable>() -> T? {
        guard let data = self.retriveData() else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
public extension Data {
    func decode<T: Decodable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
    func toDictionary(options: JSONSerialization.ReadingOptions = [.allowFragments]) -> [String: Any]? {
          return to(type: [String: Any].self, options: options)
      }

      func to<T>(type: T.Type, options: JSONSerialization.ReadingOptions = [.allowFragments]) -> T? {
          guard let result = try? JSONSerialization.jsonObject(with: self, options: options) as? T else {
              return nil
          }
          return result
      }
    var dictionary: [String: Any]? {
          do {
              return try JSONSerialization.jsonObject(with: self) as? [String: Any]
          } catch {
              print(error.localizedDescription)
          }
          return nil
    }
}
public extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
public extension Array where Element == String {
    func joinedWithAmpersands() -> String {
        joined(separator: "&")
    }
}
public extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
public enum NetworkServiceError: LocalizedError {
    case decodingError(String)
    case encodingError
    case unsuccessStatus(Int)
    case mappingError(String)
    case other
}
