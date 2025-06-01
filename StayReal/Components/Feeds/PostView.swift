//
//  PostView.swift
//  StayReal
//
//  Created by Rémy Godet on 24/04/2025.
//

import SwiftUI

import SwiftUI

struct TwoFingerDragView: UIViewRepresentable {
    var onDrag: (CGSize, CGFloat) -> Void
    
    class Coordinator: NSObject {
        var onDrag: (CGSize, CGFloat) -> Void
        
        init(onDrag: @escaping (CGSize, CGFloat) -> Void) {
            self.onDrag = onDrag
        }
        
        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard recognizer.numberOfTouches == 2 else {
                onDrag(
                    .zero,
                    0
                )
                return
            }
            
            let firstFinger = recognizer.location(ofTouch: 0, in: recognizer.view)
            let secondFinger = recognizer.location(ofTouch: 1, in: recognizer.view)
            
            let distanceX = firstFinger.x.distance(to: secondFinger.x)
            let distanceY = firstFinger.y.distance(to: secondFinger.y)
            let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
            
            let translation = recognizer.translation(in: recognizer.view)
            switch recognizer.state {
            case .changed:
                onDrag(
                    CGSize(width: translation.x, height: translation.y),
                    distance
                )
            case .ended, .cancelled, .failed, .possible:
                onDrag(
                    .zero,
                    0
                )
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDrag: onDrag)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        view.addGestureRecognizer(pan)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PostView: View {
    let post: FeedsPost
    let geo: GeometryProxy
    let isFirst: Bool
    @Binding var offset: CGFloat
    
    @State var showGUI = true
    
    @State var position: CGSize = .zero
    
    @State var primaryUrl: String
    @State var secondaryUrl: String
    
    @State var scale: CGFloat = 1
    @State var translation: CGPoint = .zero
    
    @State var address: Address?
    
    init(post: FeedsPost, geo: GeometryProxy, isFirst: Bool, offset: Binding<CGFloat>) {
        self.post = post
        self.geo = geo
        self.isFirst = isFirst
        self._offset = offset
        self.primaryUrl = post.post.primary.url
        self.secondaryUrl = post.post.secondary.url
    }
    
    func getPostHour() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = formatter.date(from: post.post.takenAt)
        return date?.formatted(date: .omitted, time: Date.FormatStyle.TimeStyle.shortened) ?? "--:--"
    }
    
    func getPostLocation() {
        if let location = post.post.location {
            Task {
                do {
                    address = try await ReverseGeocodingAPI().getPosition(location).address
                } catch {
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                WebImage(url: post.user.profilePicture?.url ?? "")
                    .mask(Circle())
                    .overlay(content: {
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    })
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user.username)
                        .font(.system(size: 16, weight: .semibold))
                    HStack(spacing: 6) {
                        HStack(spacing: 3) {
                            Image("mingcute_time_fill")
                            Text(getPostHour())
                        }
                        if post.post.location != nil {
                            if let address = address {
                                Text("\(address.city ?? address.village ?? address.town ?? address.municipality), \(address.country)")
                            } else {
                                Text("...")
                            }
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .opacity(0.6)
                }
                Spacer()
                Menu {
                    Text("Here, menu content")
                } label: {
                    Image("mingcute_more_fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(5)
                }
                
            }
            .padding(.horizontal)
            .padding(.top, isFirst ? geo.safeAreaInsets.top + 54 : 0)
            .frame(height: 70 + (isFirst ? geo.safeAreaInsets.top + 54 : 0))
            .background {
                ZStack(alignment: .top) {
                    if (!isFirst) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.background, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 70)
                            .zIndex(100)
                    }
                    WebImage(url: primaryUrl)
                        .blur(radius: 30, opaque: true)
                        .opacity(0.5)
                }
                .frame(
                    width: geo.size.width,
                    height: (geo.size.width * 4/3) + 70 + (
                        isFirst ? geo.safeAreaInsets.top:0
                    )
                )
                .offset(y: (geo.size.width * 4/3) / 2 - (
                    isFirst ? geo.safeAreaInsets.top/2:0
                ) - Double(isFirst && offset < 0 ? -offset:0))
            }
            ZStack(alignment: .bottom) {
                WebImage(url: primaryUrl)
                    .mask(RoundedRectangle(cornerRadius: translation.x == 0 && translation.y == 0 ? 0 : 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .inset(by: 0.5)
                            .stroke(.white.opacity(translation.x == 0 && translation.y == 0 ? 0 : 0.5), lineWidth: 1)
                    )
                    .scaleEffect(scale)
                    .offset(translation)
                    .frame(width: geo.size.width, height: (geo.size.width * 4/3))
                
                TwoFingerDragView { offset, distance in
                    withAnimation(.bouncy) {
                        translation.x = offset.width
                        translation.y = offset.height
                        scale = 1 + distance/400
                        showGUI = (offset.width == 0 && offset.height == 0)
                    }
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    withAnimation(.bouncy) {
                        showGUI = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } onPressingChanged: { pressed in
                    withAnimation(.bouncy) {
                        showGUI = true
                    }
                }
                WebImage(url: secondaryUrl)
                    .mask(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .inset(by: 0.5)
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    )
                    .frame(width: 130, height: 175)
                    .clipped()
                    .position(x: position.width, y: position.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.bouncy) {
                                    position.width = min(max(65, value.location.x), geo.size.width - 65)
                                    position.height = max(90, value.location.y)
                                }
                            }
                            .onEnded({ value in
                                withAnimation(.smooth) {
                                    if (value.location.x > geo.size.width / 2) {
                                        position.width = geo.size.width - 65 - 16
                                        position.height = 87.5 + 16
                                    } else {
                                        position.width = 65 + 16
                                        position.height = 87.5 + 16
                                    }
                                }
                            })
                    )
                    .onTapGesture {
                        let tmp = primaryUrl
                        primaryUrl = secondaryUrl
                        secondaryUrl = tmp
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .offset(x: showGUI ? 0 : position.width > geo.size.width / 2 ? 175 : -175)
                    .blur(radius: showGUI ? 0 : 2)
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, .background],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(height: showGUI ? 160:16)
                    .opacity(showGUI ? 1:0)
                VStack {
                    VStack(spacing: showGUI ? 5 : 10) {
                        if !(post.post.caption.isEmpty) {
                            HStack {
                                Text("**\(post.user.username)** \(post.post.caption)")
                                    .lineLimit(2)
                                    .font(.system(size: 14))
                                Spacer()
                            }
                        }
                        ForEach(post.post.comments.prefix(2 - (post.post.caption.isEmpty ? 0:1))) { comment in
                            HStack {
                                Text("**\(comment.user.username)** \(comment.content)")
                                    .lineLimit(2)
                                    .font(.system(size: 14))
                                Spacer()
                            }
                        }
                    }
                    .offset(y: showGUI ? 0 : 20)
                    .blur(radius: showGUI ? 0 : 2)
                    .opacity(showGUI ? 1:0)
                    .padding(.horizontal, 16)
                    HStack(spacing: 0) {
                        HStack(spacing: -11) {
                            ForEach(0..<min(3, post.post.realMojis.count)) { i in
                                WebImage(url: post.post.realMojis[i].media.url)
                                    .mask(Circle())
                                    .overlay(
                                        ZStack {
                                            if (i == 2 && post.post.realMojis.count > 3 ) {
                                                Circle()
                                                    .fill(
                                                        Color(
                                                            red: 0.09,
                                                            green: 0.09,
                                                            blue: 0.09
                                                        )
                                                        .opacity(0.8)
                                                    )
                                                Text("+\(post.post.realMojis.count - 2)")
                                                    .font(.system(size: 14,weight: .medium))
                                            }
                                            Circle()
                                                .inset(by: 0.5)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                            
                                        }
                                    )
                                    .frame(width: 36, height: 36)
                                    .scaleEffect(showGUI ? 1:0.5)
                                    .opacity(showGUI ? 1:0)
                                    .offset(x: showGUI ? 0 : CGFloat(-24 * i))
                                    .blur(radius: showGUI ? 0 : 4)
                                    .animation(.bouncy.delay(Double(i) * 0.05), value: showGUI)
                            }
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Image("mingcute_comment_fill")
                                .padding(5)
                        }
                        .scaleEffect(showGUI ? 1:0.5)
                        .opacity(showGUI ? 1:0)
                        .blur(radius: showGUI ? 0 : 4)
                        Button {
                            
                        } label: {
                            Image("mingcute_emoji_fill")
                                .padding(5)
                        }
                        .scaleEffect(showGUI ? 1:0.5)
                        .opacity(showGUI ? 1:0)
                        .blur(radius: showGUI ? 0 : 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom)
                    .padding(.top, 8)
                }
            }
            .clipped()
        }
        .frame(width: geo.size.width, height: (geo.size.width * 4/3) + 70 + (isFirst ? geo.safeAreaInsets.top + 54 : 0))
        .onAppear {
            position.width = geo.size.width - 65 - 16
            position.height = 87.5 + 16
        }
    }
}

#Preview {
    NavigationStack {
        AccountsContainer()
    }
    .preferredColorScheme(.dark)
}
