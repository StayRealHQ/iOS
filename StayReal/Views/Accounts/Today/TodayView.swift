//
//  TodayView.swift
//  StayReal
//
//  Created by Rémy Godet on 17/04/2025.
//

import SwiftUI
import SwiftUIX
import LucideIcons

struct TodayView: View {
    let geo: GeometryProxy
    
    @State var isRefreshing = false
    @State var offset: CGFloat = 0
    
    @State var selectedFeed: FeedsType = FeedsList.first!
    @State var feedsPost: [FeedsPost] = []
    
    var body: some View {
        ZStack(alignment: .top) {
            CocoaScrollView {
                VStack(spacing: 5) {
                    ForEach(feedsPost) { post in
                        PostView(
                            post: post,
                            geo: geo,
                            isFirst: post.id == feedsPost.first?.id,
                            offset: $offset
                        )
                    }
                }
                .padding(.top, -geo.safeAreaInsets.top)
                .padding(.bottom, 116)
            }
            .onOffsetChange { scroll in offset = scroll.value(from: .topLeading).y + geo.safeAreaInsets.top }
            .alwaysBounceVertical(true)
            .onRefresh { getFriendsPost() }
            .isRefreshing(isRefreshing)
            .task {
                getFriendsPost()
            }
            HStack {
                Menu {
                    ForEach(FeedsList) { feed in
                        Button {
                            selectedFeed = feed
                        } label: {
                            Text(feed.name)
                        }
                    }
                } label: {
                    HStack(spacing: 2) {
                        Text(selectedFeed.name)
                            .font(.system(size: 24, weight: .bold))
                        Image(uiImage: Lucide.chevronDown)
                            .resizable()
                            .renderingMode(.template)
                            .tint(.white)
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .padding(.top, 3)
                    }
                }
                Spacer()
            }
            .padding()
            .padding(.top, geo.safeAreaInsets.top)
            .frame(height: 54 + geo.safeAreaInsets.top)
            .background {
                LinearGradient(
                    stops: [
                        Gradient.Stop(
                            color: Color.background.opacity(min(1, offset / 54.0)),
                            location: 0
                        ),
                        Gradient.Stop(color: Color.background.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    
    func getFriendsPost() {
        Task {
            isRefreshing = true
            do {
                let feed = try await FeedsAPI().getFriends()
                print(feed)
                var posts: [FeedsPost] = [];
                feed.friendsPosts.forEach { friend_post in
                    friend_post.posts.forEach { post in
                        posts.append(FeedsPost(
                            post: post,
                            user: friend_post.user
                        ))
                    }
                }
                feedsPost = posts
            } catch {
                print(error)
            }
            isRefreshing = false
        }
    }
}

#Preview {
    NavigationStack {
        AccountsContainer()
    }
    .colorScheme(.dark)
}
