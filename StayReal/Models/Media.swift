//
//  Media.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

struct Media: Decodable {
    let url: String
    let width: Int
    let height: Int
    
    let mediaType: String?
    let mimeType: String?
}
