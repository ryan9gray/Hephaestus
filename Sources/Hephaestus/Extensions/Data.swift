
import Foundation

extension Dictionary {

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
extension Data {
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
    func toDictionary(options: JSONSerialization.ReadingOptions = []) -> [String: Any]? {
          return to(type: [String: Any].self, options: options)
      }

      func to<T>(type: T.Type, options: JSONSerialization.ReadingOptions = []) -> T? {
          guard let result = try? JSONSerialization.jsonObject(with: self, options: options) as? T else {
              return nil
          }
          return result
      }
}
enum NetworkServiceError: LocalizedError {
    case decodingError(String)
    case encodingError
    case unsuccessStatus(Int)
    case mappingError(String)
    case other
}
