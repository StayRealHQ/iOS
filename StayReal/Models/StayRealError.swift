//
//  StayRealError.swift
//  StayReal
//
//  Created by Rémy Godet on 18/04/2025.
//

enum StayRealError: Error {
    case noAccessTokenInKeychain
    case noDeviceIdInKeychain
    case invalidConversionToData
    case userNotFound
    case invalidResponse
    
}
