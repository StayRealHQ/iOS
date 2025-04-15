//
//  Prominent.swift
//  StayReal
//
//  Created by Rémy Godet on 10/04/2025.
//

import SwiftUI

struct ProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @State var doHaptic = false
    
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isEnabled ? .white:.white.opacity(0.3))
            .overlay {
                configuration.label
                    .font(.headline)
                    .foregroundStyle(.black)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .frame(height: 55)
            .animation(
                .bouncy(duration: 0.3, extraBounce: 0.2),
                value: configuration.isPressed
            )
            .sensoryFeedback(.impact,trigger: doHaptic)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if (isPressed == true) {
                    doHaptic.toggle()
                }
            }
    }
}

#Preview {
    NavigationView {
        Button {
            print("Clicked")
        } label: {
            Text("Prominent Button Style Demo")
        }
        .buttonStyle(ProminentButtonStyle())
    }
    .background(.black)
    .colorScheme(.dark)
}
