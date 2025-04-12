//
//  Onboarding.swift
//  StayReal
//
//  Created by Rémy Godet on 10/04/2025.
//

import SwiftUI

struct OnboardingView:View {
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack(alignment: .leading) {
                Text("Capture your moment, without artifice.")
                    .font(.largeTitle.bold())
                Text("StayReal is a client for BeReal, but with some amelioration.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(height: 170)
            NavigationLink("Get started", destination: LoginView())
            .buttonStyle(ProminentButtonStyle())
        }
        .padding()
    }
}

#Preview {
    MainContainer()
}
