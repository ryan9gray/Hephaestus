import CommonCrypto
import Foundation

public protocol CellContentViewModelProtocol {
    associatedtype DataType
    var callbackAction: ((DataType) -> Void)? { get set }
}

public protocol IdentifiableProtocol {
    var id: String { get }
}

extension IdentifiableProtocol {
    var snapshot: String {
        var value = String()
        dump(self, to: &value)
        let data = Data(value.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
