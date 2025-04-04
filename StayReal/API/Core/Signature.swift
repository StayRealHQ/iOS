import CryptoKit
import Foundation

struct Signature {
  private static let hmacKeyHex = "3536303337663461663232666236393630663363643031346532656337316233"

  private static var hmacKey: SymmetricKey {
    var key = [UInt8]()

    stride(from: 0, to: hmacKeyHex.count, by: 2).forEach { i in
      let start = hmacKeyHex.index(hmacKeyHex.startIndex, offsetBy: i)
      let end = hmacKeyHex.index(start, offsetBy: 2)
      let byte = UInt8(hmacKeyHex[start..<end], radix: 16) ?? 0
      key.append(byte)
    }

    return SymmetricKey(data: Data(key))
  }

  static func create(_ deviceId: String) -> String {
    let timezone = TimeZone.current.identifier
    let timestamp = Int(Date().timeIntervalSince1970)

    let bytes = "\(deviceId)\(timezone)\(timestamp)".data(using: .utf8)!
    let data = bytes.base64EncodedData()

    let signature = HMAC<SHA256>.authenticationCode(
      for: data,
      using: hmacKey
    )

    let prefix = "1:\(timestamp):".data(using: .utf8)!

    var combined = Data()
    combined.append(prefix)
    combined.append(Data(signature))

    return combined.base64EncodedString()
      .replacingOccurrences(of: "\n", with: "")
  }
}
