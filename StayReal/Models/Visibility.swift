//
//  Visibility.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

enum Visibility: String, Decodable {
    case friends = "friends"
    case friendsOfFriends = "friends-of-friends"
    case `public` = "public"
}
