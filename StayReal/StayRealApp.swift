import SwiftUI

@main
struct StayRealApp: App {
  var body: some Scene {
    WindowGroup {
        MainContainer()
            .environmentObject(Keychain.shared)
    }
  }
}
