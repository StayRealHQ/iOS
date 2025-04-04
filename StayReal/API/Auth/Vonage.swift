import Foundation

struct DataExchangeRequest: Codable {
  let phoneNumber: String
}

struct DataExchangeResponse: Decodable {
  let dataExchange: String
}

struct RequestCodeTokenRequest: Codable {
  let token: String
  let identifier: String // We use Arkose, so we always have to input "AR".
}

struct RequestCodeRequest: Codable {
  let tokens: [RequestCodeTokenRequest]
  let phoneNumber: String
  let deviceId: String
}

struct RequestCodeResponse: Decodable {
  let vonageRequestId: String
  let status: String
}

struct CheckCodeRequest: Codable {
  let code: String
  let vonageRequestId: String
}

enum VonageError: Error {
  case dataExchangeError(String)
  case requestCodeError(String)
  case checkCodeError(String)
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

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw VonageError.dataExchangeError(
        "Not able to get data exchange for this phone number, please check the phone number and try again."
      )
    }

    let wrapper = try JSONDecoder().decode(DataExchangeResponse.self, from: data)
    return wrapper.dataExchange
  }
  
  func sendSMS(captchaToken: String, deviceId: String, phoneNumber: String) async throws -> String {
    let url = URL(string: "\(baseURL)/request-code")!

    var request = URLRequest(url: url)
    appendHeadersForAppAPI(&request, deviceId: deviceId)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(
      RequestCodeRequest(
        tokens: [
          RequestCodeTokenRequest(token: captchaToken, identifier: "AR")
        ],
        phoneNumber: phoneNumber,
        deviceId: deviceId
      )
    )
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw VonageError.requestCodeError(
        "Not able to send SMS for this phone number, please check the phone number and try again."
      )
    }
    
    let wrapper = try JSONDecoder().decode(RequestCodeResponse.self, from: data)
    return wrapper.vonageRequestId
  }
  
  func verifySMS(code: String, deviceId: String, vonageRequestId: String) async throws -> String {
    let url = URL(string: "\(baseURL)/check-code")!

    var request = URLRequest(url: url)
    appendHeadersForAppAPI(&request, deviceId: deviceId)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(
      CheckCodeRequest(code: code, vonageRequestId: vonageRequestId)
    )
    
    let (data, response) = try await URLSession.shared.data(for: request)
    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    
    // Allows to determine whetever the code is correct or not.
    let status = json?["status"] as? String
    
    if status == "16" {
      throw VonageError.checkCodeError("Incorrect OTP code.")
    }
    else if status != "0" {
      throw VonageError.checkCodeError("Not able to verify the code, please check the code and try again.")
    }
    
    return json?["token"] as! String
  }
}
