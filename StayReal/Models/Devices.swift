//
//  Devices.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

struct Devices: Decodable {
    let clientVersion: String
    let device: String
    let deviceId: String
    let platform: String
    let language: String
    let timezone: String
}
