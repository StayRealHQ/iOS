import Foundation

struct DataExchangeRequest: Codable {
  let phoneNumber: String
}

struct DataExchangeResponse: Decodable {
  let dataExchange: String
}

enum VonageError: Error {
  case dataExchangeError(String)
}

struct VonageService {
  static let shared = VonageService()
  private let baseURL = "https://auth-l7.bereal.com/api/vonage"

  func getDataExchange(deviceId: String, phoneNumber: String) async throws -> String {
    let url = URL(string: "\(baseURL)/data-exchange")!

    var request = URLRequest(url: url)
    appendHeadersForAppAPI(&request, deviceId: deviceId)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(DataExchangeRequest(phoneNumber: phoneNumber))

    let (data, response) = try await URLSession.shared.data(for: request)

    // Check for successful response
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw VonageError.dataExchangeError(
        "Not able to get data exchange for this phone number, please check the phone number and try again."
      )
    }

    let wrapper = try JSONDecoder().decode(DataExchangeResponse.self, from: data)
    return wrapper.dataExchange
  }
}
