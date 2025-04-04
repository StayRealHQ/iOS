import Foundation

struct VerifyCustomTokenRequest: Codable {
  let returnSecureToken: Bool // Should always be true.
  let token: String
}

struct VerifyCustomTokenResponse: Decodable {
  let kind: String
  let idToken: String
  let refreshToken: String
  let expiresIn: String
  let isNewUser: Bool
}

struct FirebaseService {
  static let shared = FirebaseService()
  private let clientKey = "AIzaSyCgNTZt6gzPMh-2voYXOvrt_UR_gpGl83Q"
  
  // Returns an ID token that should be used to grant access to the app.
  func verifyCustomToken (_ token: String) async throws -> String {
    let url = URL(string: "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyCustomToken?key=\(clientKey)")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(bundleId, forHTTPHeaderField: "x-ios-bundle-identifier")
    request.httpBody = try JSONEncoder().encode(
      VerifyCustomTokenRequest(returnSecureToken: true, token: token)
    )
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let wrapper = try JSONDecoder().decode(VerifyCustomTokenResponse.self, from: data)
    
    return wrapper.idToken
  }
}
