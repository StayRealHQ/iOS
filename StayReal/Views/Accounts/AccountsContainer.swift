//
//  AccountsContainer.swift
//  StayReal
//
//  Created by Rémy Godet on 13/04/2025.
//

import SwiftUI
import LucideIcons

struct AccountsContainer: View {
    @State var tab: Int = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.background)
                    .ignoresSafeArea()
                
                // Content
                ZStack {
                    VStack {
                        if (tab == 0) {
                            TodayView(geo: geo)
                        }
                        if (tab == 1) {
                            FriendsView()
                        }
                        if (tab == 2) {
                            NotificationsView()
                        }
                        if (tab == 3) {
                            ProfileView(geo: geo)
                        }
                    }
                    .ignoresSafeArea()
                    .mask {
                        Rectangle()
                            .ignoresSafeArea()
                            .padding(.bottom, 1)
                    }
                }
                // TabBar
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(
                            stops: [
                                Gradient.Stop(color: .background, location: 0),
                                Gradient.Stop(color: .background.opacity(0.7),location: 0.5),
                                Gradient.Stop(color: .background.opacity(0),location: 1)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                    HStack {
                        Button("Today") { tab = 0 }
                            .buttonStyle(TabItem(icon: Lucide.sun, active: tab == 0))
                        Button("Friends") { tab = 1 }
                            .buttonStyle(TabItem(icon: Lucide.usersRound, active: tab == 1))
                        Button("Camera") { }
                            .buttonStyle(CameraTab())
                            .offset(y: -10)
                        Button("Notifications") { tab = 2 }
                            .buttonStyle(TabItem(icon: Lucide.bell, active: tab == 2))
                        Button("You") { tab = 3 }
                            .buttonStyle(TabItem(icon: Lucide.userRound, active: tab == 3))
                    }
                }
                .frame(height: 65)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountsContainer()
    }
    .preferredColorScheme(.dark)
}
