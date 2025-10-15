import SwiftUI
import Combine


// Watchlist
class WatchlistManager: ObservableObject {
    // Published list for storing watchlist data
    @Published var watchlist: [SimpleMovie] = []

    // Add a movie to the watchlist
    func add(movie: SimpleMovie) {
        // If the movie isn't already in the watchlist
        if !watchlist.contains(where: { $0.id == movie.id }) {
            watchlist.append(movie)
        }
    }

    // Remove a movie from the watchlist
    func remove(movie: SimpleMovie) {
        // Remove all movies where the id matches
        watchlist.removeAll { $0.id == movie.id }
    }
}
