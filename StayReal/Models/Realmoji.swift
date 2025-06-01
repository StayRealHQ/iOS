//
//  Realmojis.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

enum RealmojiType: String, Decodable {
    case happy
    case up
    case heartEyes
    case surprised
    case laughing
}

struct Realmoji: Decodable, Identifiable {
    let id: String?
    let user: User?
    let emoji: String
    let media: Media
    let type: RealmojiType?
    let isInstant: Bool
    let postedAt: String?
}
