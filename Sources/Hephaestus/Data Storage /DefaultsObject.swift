
import Foundation

@objcMembers class DefaultsObject: NSObject {
    
    static var objectDictionary: [String: AnyObject] = [:]
    
    func saveToDefaults() {
        let className = String(describing: type(of: self))
        let defaults = UserDefaults.standard
        let encodedObject = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        defaults.set(encodedObject, forKey: className)
        defaults.synchronize()
        DefaultsObject.objectDictionary[className] = self
    }
    
    static func fromDefaults() -> Self {
        return fromDefaults(self)
    }
    
    fileprivate static func fromDefaults<T>(_ type: T.Type) -> T where T: NSObject {
        let className = String(describing: T.self)
        if let object = objectDictionary[className] as? T {
            return object
        } else {
            if let encodedObject = UserDefaults.standard.object(forKey: className) as? Data,
                let object = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedObject) as? T {
                objectDictionary[className] = object
                return object
            } else {
                let object = T()
                objectDictionary[className] = object
                (object as! DefaultsObject).saveToDefaults()
                return object
            }
        }
    }
    
    // MARK: - NSCoding
    
    @objc func encodeWithCoder(_ aCoder: NSCoder) {
        var baseMirror: Mirror? = Mirror(reflecting: self)
        
        while let mirror = baseMirror {
            for child in mirror.children {
                if let label = child.label {
                    aCoder.encode(self.value(forKey: label), forKey: label)
                }
            }
            baseMirror = mirror.superclassMirror
        }
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        var baseMirror: Mirror? = Mirror(reflecting: self)
        
        while let mirror = baseMirror {
            for child in mirror.children {
                if let label = child.label {
                    if aDecoder.containsValue(forKey: label) {
                        do {
                            let value = aDecoder.decodeObject(forKey: label)
                            if let value = value {
                                var objectValue = value as AnyObject?
                                try validateValue(&objectValue, forKey: label)
                            }
                            setValue(value, forKey: label)
                        } catch {
                        }
                    }
                }
            }
            baseMirror = mirror.superclassMirror
        }
    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
