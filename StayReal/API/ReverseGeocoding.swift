//
//  ReverseGeocoding.swift
//  StayReal
//
//  Created by Rémy Godet on 25/04/2025.
//


import Foundation

struct ReverseGeocodingAPI {
    private let baseURL = "https://nominatim.openstreetmap.org/reverse"
    
    func getPosition (_ location: Location) async throws -> ReverseGeocoding {
        
        // Get the access token and device id from the Keychain
        guard let accessToken = Keychain.shared.getAccessToken() else {
            throw StayRealError.noAccessTokenInKeychain
        }
        guard let deviceId = Keychain.shared.getDeviceID() else {
            throw StayRealError.noDeviceIdInKeychain
        }
        
        // Create the request
        let url = URL(string: "\(baseURL)?lat=\(location.latitude)&lon=\(location.longitude)&format=json")!
        var request = URLRequest(url: url)
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Get the data from the request
        if let httpResponse = response as? HTTPURLResponse {
            
            if (httpResponse.statusCode != 200) {
                throw StayRealError.invalidResponse
            }
            
            return try JSONDecoder().decode(ReverseGeocoding.self, from: data)
        }
        throw StayRealError.invalidConversionToData
    }
}
