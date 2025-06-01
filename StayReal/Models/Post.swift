//
//  Post.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

enum PostType: String, Decodable {
    case `default`
    case bts
}

enum PostOrigin: String, Decodable {
    case own
    case repost
}

struct Post: Decodable, Identifiable {
    let id: String
    let userId: String
    let momentId: String
    let primary: Media
    let secondary: Media
    let caption: String
    let location: Location?
    let realMojis: [Realmoji]
    let comments: [Comment]
    let music: Music?
    let tags: [Tags]
    let retakeCounter: Int
    let lateInSeconds: Int
    let isLate: Bool
    let isMain: Bool
    let isFirst: Bool
    let isResurrected: Bool
    let visibility: [Visibility]
    let postedAt: String
    let takenAt: String
    let creationDate: String
    /** @deprecated use `creationDate` instead */
    let createdAt: String
    let updatedAt: String
    let postType: PostType
    let origin: PostOrigin?
    
    let parentPostId: String?
    let parentPostUserId: String?
    let parentPostUsername: String?
    
    let btsMedia: Media?
    
    let screenshots: [Screenshot]?
    let unblurCount: Int?
}

struct UserPost: Decodable {
    let user: User
    let momentId: String
    let posts: [Post]
    let contentMappingEnabled: Bool
}

struct FriendPost: Decodable {
    let user: User
    let momentId: String
    let region: String
    let posts: [Post]
    let contentMappingEnabled: Bool
}

struct FeedsPost: Identifiable {
    let post: Post
    let user: User
    
    var id: String {
        return post.id
    }
}
