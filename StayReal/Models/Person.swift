//
//  Person.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

enum userFreshness: String, Decodable {
    case returning
    case new
}

enum userGender: String, Decodable {
    case MALE
    case FEMALE
}

struct PersonInterface_Me: Decodable {
    let id: String
    let username: String
    let birthdate: String
    let fullname: String
    let profilePicture: Media?
    let realmojis: [Realmoji]
    let devices: [Devices]
    let canDeletePost: Bool
    let canPost: Bool
    let canUpdateRegion: Bool
    let phoneNumber: String
    let biography: String
    let location: String
    let countryCode: String
    /**
     * used to know which region to check for the bereal moment
     * @example "europe-west"
     */
    let region: String
    /** @example "2024-04-12T22:07:19.431Z" */
    let createdAt: String
    let isRealPeople: Bool
    let userFreshness: userFreshness
    let streakLength: Int
    let lastBtsPostAt: String
    /**
     *  Always set as "USER"
     */
    let type: String
    /**
     *  Todo: Find what is used in Links
     */
    //let links: Unknown
    let gender: userGender
    let isPrivate: Bool
    let accountDeleteScheduledAt: String?
}

struct User: Decodable, Identifiable {
    let id: String
    let username: String
    let fullname: String?
    let profilePicture: Media?
    let type: String
}
