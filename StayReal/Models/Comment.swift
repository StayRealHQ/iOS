//
//  Comment.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

struct Comment: Decodable, Identifiable {
    let id: String
    let user: User
    let content: String
    let postedAt: String
}
