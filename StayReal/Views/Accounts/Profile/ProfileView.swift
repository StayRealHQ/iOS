//
//  ProfileView.swift
//  StayReal
//
//  Created by Rémy Godet on 17/04/2025.
//


import SwiftUI
import LucideIcons
import SwiftUIX

struct ProfileHeader: View {
    let geo: GeometryProxy
    @Binding var offset: CGFloat
    
    var body: some View {
        ZStack {
            WebImage(url: "https://avatars.githubusercontent.com/u/77058107?v=4")
                .blur(radius: 15, opaque: true)
                .ignoresSafeArea()
                .frame(height: 280 + geo.safeAreaInsets.top)
                .scaleEffect(offset > 0 ? 1 : 1 + -(offset/200))
                .offset(y: (offset - geo.safeAreaInsets.top) + (offset > 190 ? -190/1.5:-offset/1.5))
                .zIndex(0)
                .mask {
                    Rectangle()
                        .offset(y: offset - geo.safeAreaInsets.top - (offset > 190 ? 190 : offset) - (offset > 0 ? 0: -offset))
                        .frame(height: 309 + geo.safeAreaInsets.top + (offset > 0 ? 0: -(offset * 2)))
                }
            
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Spacer()
                    HStack {
                        Spacer()
                        WebImage(url: "https://avatars.githubusercontent.com/u/77058107?v=4")
                            .mask(Circle())
                            .overlay(content: {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            })
                            .frame(width: 120, height: 120)
                            .scaleEffect(max(0, min(1, 1 - (offset/250))),anchor: .bottom)
                            .blur(radius: offset/10)
                            .opacity(Double(1 - offset/190))
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        Text("Rémy Godet")
                            .font(.system(size: min(28, max(18, 28 - (offset / 16))), weight: .bold, design: .default))
                        Text("@rgodet")
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                    .frame(height: 60)
                    .padding(.bottom, min(30, max(5, 30 - 30 * (offset / 190))))
                }
                .zIndex(200000)
                .frame(height: 250)
                .background {
                    LinearGradient(
                        colors: [
                            .background.opacity(0),
                            .background
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .offset(y: offset > 190 ? offset - 190 : 0)
            }
        }
        .overlay(content: {
            VStack {
                Spacer()
                Rectangle()
                    .fill(.white)
                    .opacity(Double(min(0.1, offset / 1000)))
                    .frame(height: 1)
                    .padding(.top, -46)
                    .offset(y: offset > 190 ? offset - 190: 0)
            }
        })
        .frame(height: 250)
    }
}

struct GridMemoryItem: View {
    let memory: Memory

    var body: some View {
        ZStack(alignment: .topTrailing) {
            WebImage(url: memory.thumbnail.url)
            WebImage(url: memory.primary.url)
            WebImage(url: memory.secondary.url)
                .aspectRatio(3/4, contentMode: .fit)
                .frame(width: 45)
                .mask(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                        .inset(-0.5)
                }
                .padding(.top, 5)
                .padding(.trailing, 5)
        }
        .contextMenu {
            Button {
                
            } label: { Label("Pin on my profile", systemImage: "pin") }
            Button {
                
            } label: { Label("Share", systemImage: "square.and.arrow.up") }
            Button {
                
            } label: { Label("Save in Library", systemImage: "square.and.arrow.down") }
            Button {
                
            } label: { Label("Update visibility", systemImage: "eye") }
            Button(role: .destructive) {
                
            } label: { Label("Delete post", systemImage: "trash") }
        } preview: {
            ZStack(alignment: .topTrailing) {
                WebImage(url: memory.thumbnail.url)
                WebImage(url: memory.primary.url)
                    .aspectRatio(3/4, contentMode: .fit)
                WebImage(url: memory.secondary.url)
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(width: 140)
                    .mask(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                            .inset(-0.5)
                    }
                    .padding()
            }
            
        }
    }
}


struct ProfileView: View {
    let geo: GeometryProxy
    
    @State var profile: PersonInterface_Me?
    @State var memories: MemoriesFeeds?
    
    @State var offset: CGFloat = 0
    var body: some View {
        CocoaScrollView {
            VStack(spacing: 0) {
                ProfileHeader(geo: geo, offset: $offset)
                
                VStack(spacing: 0) {
                    HStack {
                        Button {

                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.5)
                                        .stroke(.white.opacity(0.05), lineWidth: 1)
                                    Text("Update the profile")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .frame(height: 50)
                        }
                        NavigationLink { SettingsView() } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.5)
                                        .stroke(.white.opacity(0.05), lineWidth: 1)
                                    Image(uiImage: Lucide.settings)
                                        .renderingMode(.template)
                                        .resizable()
                                        .tint(.white)
                                        .frame(width: 20, height: 20)
                                }
                                .frame(width: 50, height: 50)
                        }
                    }
                    .padding()
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3),
                        alignment: .leading,
                        spacing: 2
                    ) {
                        if let memories = memories {
                            ForEach(memories.data) { memory in
                                GridMemoryItem(memory: memory)
                                    .aspectRatio(3/4, contentMode: .fit)
                            }
                        } else {
                            ForEach(0..<3) { _ in
                                SkeletonGradient()
                                    .aspectRatio(3/4, contentMode: .fit)
                            }
                        }
                    }
                }
                .zIndex(-10)
            }
            .padding(.bottom, 116)
        }
        .onOffsetChange { scroll in offset = scroll.value(from: .topLeading).y + geo.safeAreaInsets.top }
        .alwaysBounceVertical(true)
        .task {
            Task {
                memories = try await FeedsAPI().getMemories()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountsContainer(tab: 3)
    }
    .preferredColorScheme(.dark)
}

