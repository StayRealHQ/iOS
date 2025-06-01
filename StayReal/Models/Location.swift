//
//  Location.swift
//  StayReal
//
//  Created by Rémy Godet on 18/04/2025.
//

struct Location: Decodable {
    let longitude: Double
    let latitude: Double
}

struct Address: Decodable {
    let city: String?
    let village: String?
    let municipality: String
    let country: String
    let town: String?
}

struct ReverseGeocoding: Decodable {
    let address: Address
}
