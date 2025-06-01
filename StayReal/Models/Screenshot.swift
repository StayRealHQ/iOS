//
//  Screenshot.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

struct Screenshot: Decodable {
    let id: String
    let postId: String
    let snappedAt: String
    let user: User
}
