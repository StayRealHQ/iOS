//
//  WebImage.swift
//  StayReal
//
//  Created by Rémy Godet on 17/04/2025.
//

import SwiftUI
import LucideIcons
import CachedAsyncImage

struct SkeletonGradient: View {
    let background: Color = Color(red: 0.1, green: 0.1, blue: 0.1)
    let foreground: Color = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    @State private var position: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .fill(background)
                Rectangle()
                    .fill(
                        LinearGradient(colors: [
                            foreground.opacity(0),
                            foreground,
                            foreground.opacity(0)
                        ], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(
                        width: geo.size.width * 2,
                        height: geo.size.height * 2
                    )
                    .offset(x: position, y: 0)
                    .rotationEffect(.degrees(45))
            }
            .compositingGroup()
            .frame(
                width: geo.size.width,
                height: geo.size.height,
            )
            .clipped()
            .onAppear {
                position = -geo.size.width * 2
                
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    position = geo.size.width * 2
                }
            }
        }
    }
}

struct WebImage: View {
    let url: String
    
    var body: some View {
        CachedAsyncImage(
            url: url,
            placeholder: { _ in
                SkeletonGradient()
            },
            image: {
                Image(uiImage: $0)
                    .resizable()
                    .scaledToFill()
            },
            error: { error, retry in
                ZStack {
                    SkeletonGradient()
                    Rectangle()
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                    Button {
                        retry()
                    } label: {
                        Image(uiImage: Lucide.refreshCw)
                            .resizable()
                            .renderingMode(.template)
                            .tint(.white)
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    
                }
            }
        )
    }
}

#Preview {
    ZStack {
        Color.background
            .ignoresSafeArea()
        WebImage(url: "https://fastly.picsum.photos/id/83/200/200.jpg?hmac=PWpSDFTveI1bSJjmrf_vnw4ipqEELicSPpDf8jb89FI")
            .mask(Circle())
            .overlay{
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 2)
            }
            .frame(width: 128, height: 128)
    }
    .preferredColorScheme(.dark)
}
