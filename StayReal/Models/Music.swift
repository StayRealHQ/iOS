//
//  Music.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

enum MusicProvider: String, Decodable {
    case apple
    case spotify
}

struct Music: Decodable {
    let isrc: String
    let track: String
    let artist: String
    let artwork: String // URL of the artwork
    let preview: String? // .m4a audio preview URL, only for Apple Music.
    let openUrl: String // URL to open the music on their respective store (Apple Music, Spotify)
    let visibility: String
    let provider: MusicProvider
    let providerId: String
    let audioType: String
}
