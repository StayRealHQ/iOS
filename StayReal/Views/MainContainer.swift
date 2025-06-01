//
//  MainContainer.swift
//  StayReal
//
//  Created by Rémy Godet on 10/04/2025.
//

import SwiftUI

struct MainContainer: View {
    @EnvironmentObject var keychain: Keychain
    
    init() {
        SetupNavigationBarApparence()
    }
    
    var body: some View {
        if (keychain.loggedIn) {
            NavigationStack() {
                AccountsContainer()
            }
            .colorScheme(.dark)
        } else {
            NavigationStack() {
                OnboardingView()
                    .background(Color.background)
            }
            .colorScheme(.dark)
        }
    }
}

#Preview {
    MainContainer()
        .environmentObject(Keychain.shared)
}

