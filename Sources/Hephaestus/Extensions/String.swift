import UIKit
import Foundation
import UIKit
import CryptoKit
import Foundation
import CommonCrypto

extension String {
    var localized: Self {
        NSLocalizedString(self, comment: "")
    }
    
    func md5() -> String {
        guard
            let data = self.data(using: .utf8)
        else { return "nil" }

        if #available(iOS 13.0, *) {
            return Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
        } else {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            data.withUnsafeBytes { bytes in
                _ = CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
            }
            return digest.makeIterator().map { String(format: "%02x", $0) }.joined()
        }
    }

    func substring(with range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func contains(from characterSet: CharacterSet) -> Bool {
        rangeOfCharacter(from: characterSet) != nil
    }

	func fromBase64() -> String? {
		guard let data = Data(base64Encoded: self) else {
			return nil
		}

		return String(data: data, encoding: .utf8)
	}

	func toBase64() -> String {
		return Data(self.utf8).base64EncodedString()
	}
}
