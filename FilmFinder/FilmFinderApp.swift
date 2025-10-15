import SwiftUI

@main
struct FilmFinderApp: App {
    @StateObject private var watchlistManager = WatchlistManager()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(watchlistManager)
        }
    }
}
