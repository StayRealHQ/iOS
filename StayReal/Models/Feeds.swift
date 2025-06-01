//
//  Feeds.swift
//  StayReal
//
//  Created by Rémy Godet on 18/04/2025.
//

struct FriendsFeeds: Decodable {
    let userPosts: UserPost
    let friendsPosts: [FriendPost]
    let remainingPosts: Int
    let maxPostsPerMoment: Int
}

struct MemoriesFeeds: Decodable {
    let data: [Memory]
    let next: String?
    let memoriesSynchronized: Bool
}

struct FeedsType: Identifiable {
    let id: String
    let name: String
}

let FeedsList: [FeedsType] = [
    .init(
        id: "friends",
        name: "Friends"
    ),
    .init(
        id: "friends-of-friends",
        name: "Friends of friends"
    )
]
