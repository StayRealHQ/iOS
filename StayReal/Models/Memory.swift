//
//  Memory.swift
//  StayReal
//
//  Created by Rémy Godet on 18/04/2025.
//

struct Memory: Decodable, Identifiable {
    let id: String
    let thumbnail: Media
    let primary: Media
    let secondary: Media
    let isLate: Bool
    let memoryDay: String
    let location: Location?
}
