import Foundation

struct Tokens: Decodable {
  let token_type: String
  let access_token: String
  let expires_in: Int
  let scope: String
  let refresh_token: String
}

struct FirebaseTokenRequest: Codable {
  let token: String
  let client_id: String
  let grant_type: String
  let client_secret: String
}

struct RefreshTokenRequest: Codable {
  let refresh_token: String
  let client_id: String
  let grant_type: String
  let client_secret: String
}

enum TokenError: Error {
  case invalidResponse(String)
}

struct TokenService {
  static let shared = TokenService()
  private let clientSecretKey = "962D357B-B134-4AB6-8F53-BEA2B7255420"
  private let baseURL = "https://auth-l7.bereal.com/token"
  
  func grantFirebase (idToken: String, deviceId: String) async throws -> Tokens {
    let url = URL(string: "\(baseURL)?grant_type=firebase")!
    
    var request = URLRequest(url: url)
    appendHeadersForAppAPI(&request, deviceId: deviceId)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(
      FirebaseTokenRequest(token: idToken, client_id: "ios", grant_type: "firebase", client_secret: clientSecretKey)
    )
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
      throw TokenError.invalidResponse(
        "Failed to generate authentication tokens from Firebase."
      )
    }

    return try JSONDecoder().decode(Tokens.self, from: data)
  }
  
  func refresh(token: String, deviceId: String) async throws -> Tokens {
    let url = URL(string: baseURL)!
    
    var request = URLRequest(url: url)
    appendHeadersForAppAPI(&request, deviceId: deviceId)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(
      RefreshTokenRequest(refresh_token: token, client_id: "ios", grant_type: "refresh_token", client_secret: clientSecretKey)
    )
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
      throw TokenError.invalidResponse(
        "Failed to refresh tokens."
      )
    }

    return try JSONDecoder().decode(Tokens.self, from: data)
  }

}
