//
//  Keychain.swift
//  StayReal
//
//  Created by Rémy Godet on 12/04/2025.
//

import Foundation
import Security

enum KeychainError: Error {
    case accessTokenMissing
    case refreshTokenMissing
    case deviceIdMissing
}

class Keychain: ObservableObject {
    static let shared: Keychain = Keychain()
    
    @Published var loggedIn: Bool = false
    
    private func set(key: String, value: String) -> Bool {
        // Transfom String to Data
        let data = value.data(using: .utf8)!
        
        // Generate the query - Set only accessible when the device is unlocked
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Delete if already exist
        SecItemDelete(query as CFDictionary)
        
        // Add the value to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else {
            print("Failed to store \(key) in the Keychain. Status code: \(status)")
            return false
        }
    }
    
    private func get(key: String) -> String? {
        // Generate the query - Only get one value
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Get the data from the Keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // Check for data and convert it as String
        if status == errSecSuccess,
            let data = item as? Data,
            let token = String(data: data, encoding: .utf8) {
            return token
        } else {
            print("Failed to retrieve \(key) from the Keychain. Status code: \(status)")
            return nil
        }
    }
    
    private func remove(key: String) -> Bool {
        // Generate the query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Deleting the key
        let status = SecItemDelete(query as CFDictionary)
        
        // Return the status
        if (status == errSecSuccess) {
            return true
        } else {
            print("Failed to delete \(key) from the Keychain. Status code: \(status)")
            return false
        }
    }
    
    func setAccessToken(_ accessToken: String) -> Bool {
        return set(key: "access_token", value: accessToken)
    }
    
    func setRefreshToken(_ refreshToken: String) -> Bool {
        return set(key: "refresh_token", value: refreshToken)
    }
    
    func setDeviceID(_ deviceID: String) -> Bool {
        return set(key: "device_id", value: deviceID)
    }
    
    func setCredentials(accessToken: String, refreshToken: String, deviceID: String) -> Bool {
        if (setAccessToken(accessToken) && setRefreshToken(refreshToken) && setDeviceID(deviceID)) {
            loggedIn = true
            return true
        }
        return false
    }
    
    func getAccessToken() -> String? {
        return get(key: "access_token")
    }
    
    func getRefreshToken() -> String? {
        return get(key: "refresh_token")
    }
    
    func getDeviceID() -> String? {
        return get(key: "device_id")
    }
    
    func removeAccessToken() -> Bool {
        return remove(key: "access_token")
    }
    
    func removeRefreshToken() -> Bool {
        return remove(key: "refresh_token")
    }
    
    func removeDeviceID() -> Bool {
        return remove(key: "device_id")
    }
    
    func removeCredentials() -> Bool {
        if (removeAccessToken() && removeRefreshToken() && removeDeviceID()) {
            loggedIn = false
            return true
        }
        return false
    }
    
    func refreshCredentials() async throws -> Bool {
        
        // Get requested parameters
        guard let refreshToken = getRefreshToken() else { throw KeychainError.refreshTokenMissing }
        guard let deviceID = getDeviceID() else { throw KeychainError.deviceIdMissing }
        
        // Refresh the token
        let token = try await TokenService().refresh(
            token: refreshToken,
            deviceId: deviceID
        )
        
        // Save token in the Keychain
        return (setAccessToken(token.access_token) && setRefreshToken(token.refresh_token))
    }
    
    private init() {
        loggedIn = getAccessToken() == nil ? false : true
    }
}
