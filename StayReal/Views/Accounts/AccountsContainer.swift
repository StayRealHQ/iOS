//
//  AccountsContainer.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

import SwiftUI

struct AccountsContainer: View {
    @EnvironmentObject var keychain: Keychain
    
    @State var accessToken: String?
    
    var body: some View {
        Text("Access token: \(accessToken ?? "Not set")")
            .task {
                accessToken = keychain.getAccessToken()
            }
        Button {
            Task {
                do {
                    let user = try await Person().getMe()
                    print(user)
                } catch {
                    print("Error: \(error)")
                }
            }
        } label: {
            Text("Get info about current user")
        }

        Button {
            keychain.removeCredentials()
        } label: {
            Text("Logout")
        }
        .padding(.top, 50)
    }
}
