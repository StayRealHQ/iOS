//
//  Person.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

import Foundation

struct Person {
    private let baseURL = "https://mobile-l7.bereal.com/api/person"
    
    func getMe () async throws -> PersonInterface_Me {
        
        // Get the access token and device id from the Keychain
        guard let accessToken = Keychain.shared.getAccessToken() else {
            throw StayRealError.noAccessTokenInKeychain
        }
        guard let deviceId = Keychain.shared.getDeviceID() else {
            throw StayRealError.noDeviceIdInKeychain
        }
        
        // Create the request
        let url = URL(string: "\(baseURL)/me")!
        var request = URLRequest(url: url)
        appendHeadersForAppAPI(&request, deviceId: deviceId)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Get the data from the request
        if let httpResponse = response as? HTTPURLResponse {
            
            // Error : Token expired
            if (httpResponse.statusCode == 401) {
                try await Keychain.shared.refreshCredentials()
                return try await getMe()
            }
            
            // Error : User not exist (yes, really)
            if (httpResponse.statusCode == 404) {
                throw StayRealError.userNotFound
            }
            
            return try JSONDecoder().decode(PersonInterface_Me.self, from: data)
        }
        throw StayRealError.invalidConversionToData
    }
}
