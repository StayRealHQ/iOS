//
//  FeedsAPI.swift
//  StayReal
//
//  Created by Rémy Godet on 18/04/2025.
//

import Foundation

struct FeedsAPI {
    private let baseURL = "https://mobile-l7.bereal.com/api/feeds"
    
    func getFriends () async throws -> FriendsFeeds {
        
        // Get the access token and device id from the Keychain
        guard let accessToken = Keychain.shared.getAccessToken() else {
            throw StayRealError.noAccessTokenInKeychain
        }
        guard let deviceId = Keychain.shared.getDeviceID() else {
            throw StayRealError.noDeviceIdInKeychain
        }
        
        // Create the request
        let url = URL(string: "\(baseURL)/friends-v1")!
        var request = URLRequest(url: url)
        appendHeadersForAppAPI(&request, deviceId: deviceId)
        request.setValue(UUID().uuidString, forHTTPHeaderField: "If-None-Match")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Get the data from the request
        if let httpResponse = response as? HTTPURLResponse {
            
            // Error : Token expired
            if (httpResponse.statusCode == 401) {
                try await Keychain.shared.refreshCredentials()
                return try await getFriends()
            }
            
            return try JSONDecoder().decode(FriendsFeeds.self, from: data)
        }
        throw StayRealError.invalidConversionToData
    }
    
    func getMemories () async throws -> MemoriesFeeds {
        
        // Get the access token and device id from the Keychain
        guard let accessToken = Keychain.shared.getAccessToken() else {
            throw StayRealError.noAccessTokenInKeychain
        }
        guard let deviceId = Keychain.shared.getDeviceID() else {
            throw StayRealError.noDeviceIdInKeychain
        }
        
        // Create the request
        let url = URL(string: "\(baseURL)/memories")!
        var request = URLRequest(url: url)
        appendHeadersForAppAPI(&request, deviceId: deviceId)
        request.setValue(UUID().uuidString, forHTTPHeaderField: "If-None-Match")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Get the data from the request
        if let httpResponse = response as? HTTPURLResponse {
            
            // Error : Token expired
            if (httpResponse.statusCode == 401) {
                try await Keychain.shared.refreshCredentials()
                return try await getMemories()
            }
            
            return try JSONDecoder().decode(MemoriesFeeds.self, from: data)
        }
        throw StayRealError.invalidConversionToData
    }
}
