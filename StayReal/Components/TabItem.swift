//
//  TabItem.swift
//  StayReal
//
//  Created by Rémy Godet on 17/04/2025.
//

import SwiftUI

struct TabItem: ButtonStyle {
    let icon: UIImage
    let active: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 5) {
                Image(uiImage: icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(active ? .white : Color(red: 0.53, green: 0.53, blue: 0.53))
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                configuration.label
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(active ? .white : Color(red: 0.53, green: 0.53, blue: 0.53))
            }
            .animation(.none, value: configuration.isPressed)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .onChange(of: configuration.isPressed) {
                if (configuration.isPressed) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            Spacer()
        }
    }
}

#Preview(body: {
    AccountsContainer()
        .preferredColorScheme(.dark)
})
