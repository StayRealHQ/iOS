//
//  MainContainer.swift
//  StayReal
//
//  Created by Rémy Godet on 10/04/2025.
//

import SwiftUI

struct MainContainer: View {
    init() {
        SetupNavigationBarApparence()
    }
    
    var body: some View {
        NavigationStack {
            OnboardingView()
                .background(Color.background)
        }
        .colorScheme(.dark)
    }
}

#Preview {
    MainContainer()
}
