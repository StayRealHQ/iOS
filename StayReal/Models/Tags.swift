//
//  Tags.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

struct Tags: Decodable {
    let user: User
    let userId: String
    let replaceText: String
    let searchText: String
    let endIndex: Int
    let isUntagged: Bool
    let type: String
}
