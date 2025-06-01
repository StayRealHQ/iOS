//
//  SettingsView.swift
//  StayReal
//
//  Created by Rémy Godet on 18/04/2025.
//

import SwiftUI
import LucideIcons

struct SettingsView: View {
    var body: some View {
        List {
            Section("Privacy") {
                NavigationLink { Text("Not ready yet") } label: {
                    HStack(spacing: 10) {
                        Image(uiImage: Lucide.ban)
                            .renderingMode(.template)
                            .resizable()
                            .tint(Color.white)
                            .frame(width: 26, height: 26)
                        VStack(alignment: .leading) {
                            Text("Blocked users")
                                .font(.headline)
                            Text("No friends blocked.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section("About") {
                Link(destination: URL(string: "https://github.com/StayRealHQ/")!) {
                    HStack(spacing: 10) {
                        Image(uiImage: Lucide.github)
                            .renderingMode(.template)
                            .resizable()
                            .tint(Color.white)
                            .frame(width: 26, height: 26)
                        VStack(alignment: .leading) {
                            Text("StayReal on GitHub")
                                .font(.headline)
                            Text("Discover the code behind StayReal.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Link(destination: URL(string: "https://github.com/StayRealHQ/iOS/issues/new/choose")!) {
                    HStack(spacing: 10) {
                        Image(uiImage: Lucide.bug)
                            .renderingMode(.template)
                            .resizable()
                            .tint(Color.white)
                            .frame(width: 26, height: 26)
                        VStack(alignment: .leading) {
                            Text("Open an issue")
                                .font(.headline)
                            Text("Make suggestions or report bugs.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section() {
                Button() {
                    
                } label: {
                    HStack(spacing: 10) {
                        Image(uiImage: Lucide.logOut)
                            .renderingMode(.template)
                            .resizable()
                            .tint(Color.stayRealRed)
                            .frame(width: 26, height: 26)
                        VStack(alignment: .leading) {
                            Text("Log out")
                                .font(.headline)
                            Text("This will delete all the data from StayReal")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .background(Color.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        AccountsContainer(tab: 3)
    }
    .preferredColorScheme(.dark)
}
