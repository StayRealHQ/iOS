//
//  CameraTab.swift
//  StayReal
//
//  Created by Rémy Godet on 17/04/2025.
//

import SwiftUI

struct CameraTab: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            ZStack {
                Capsule()
                    .fill(.white)
                Image("camera_fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
            .scaleEffect(configuration.isPressed ? 0.95:1)
            .frame(width: 75, height: 50)
            .animation(
                .bouncy(duration: 0.3, extraBounce: 0.4),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) {
                if (configuration.isPressed) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            }
            Spacer()
        }
    }
}

#Preview(body: {
    AccountsContainer()
})
