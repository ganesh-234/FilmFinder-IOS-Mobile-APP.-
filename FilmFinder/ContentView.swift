import SwiftUI
import PhotosUI
import MapKit

struct SimpleMovie: Identifiable {
    let id: String
    let title: String
    let year: String
    let poster: String
}

struct MovieDetails: Identifiable, Decodable {
    var id: String { imdbID }
    let title: String
    let year: String
    let rated: String
    let released: String
    let runtime: String
    let genre: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let language: String
    let country: String
    let awards: String
    let poster: String
    let imdbRating: String
    let imdbVotes: String
    let imdbID: String
    let type: String
    let response: String

    // Custom coding keys to map JSON keys to Swift names
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case country = "Country"
        case awards = "Awards"
        case poster = "Poster"
        case imdbRating, imdbVotes, imdbID, type = "Type", response = "Response"
    }
}


struct HomeView: View {

    var body: some View {
        NavigationView {
            VStack {
                // App Logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 300)
                    .shadow(radius: 5)
                    .padding()

                // App Description
                Text("The easiest way to find what to watch.")
                    .bold()
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 30/255))
                    .padding()
                    .shadow(radius: 10)
                    .multilineTextAlignment(.center)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Image("background")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.5)
                .opacity(0.3))
        }
    }
}

struct SearchView: View{
    @State private var scrollProxy: ScrollViewProxy? = nil // Programmatic scrolling
    @State private var resultText: String = "Start searching to get started!"
    @State private var movies: [SimpleMovie] = []
    @State private var searchText: String = ""
    @State private var currentPage: Int = 1
    @State private var pageCount: Int = 1
    @State private var recentSearches: [String] = []
    
    var body: some View {
        NavigationView{
                VStack{
                    // Search bar
                    HStack {
                         Image(systemName: "magnifyingglass")
                         TextField("Search movies...", text: $searchText) // Input field
                             .textFieldStyle(PlainTextFieldStyle())
                             .onSubmit { // When user presses ENTER
                                 currentPage = 1 // Reset the page
                                 scrollToTop() // Scroll to the top
                                 performSearch() // Search function
                             }
                     }
                     .padding()
                     .background(Color(.systemGray6))
                     .cornerRadius(35)
                     .padding()
                    
                    if searchText.isEmpty && !recentSearches.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Searches")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(recentSearches, id: \.self) { term in
                                Button(action: {
                                    searchText = term
                                    currentPage = 1
                                    scrollToTop()
                                    performSearch()
                                }) {
                                    Text(term)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 1)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    // Text for status/info
                    Text(resultText)
                    // Results ScrollView
                    ScrollViewReader { proxy in
                        ScrollView {
                            Color.clear
                                .frame(height: 0)
                                .id("top") // Invisible archor at the top of the page for scrolling
                            
                            HStack{
                                // Split movies into two columns
                                movieColumn(for: leftMovies)
                                movieColumn(for: rightMovies)
                            }
                        }
                        .navigationBarHidden(true)
                        .onAppear {
                            scrollProxy = proxy
                            loadRecentSearches()
                            
                        } // Store scrll proxy
                    }
                // Pagination controls
                HStack {
                    Button("Previous") {
                        if currentPage > 1 {
                            currentPage -= 1
                            performSearch()
                            scrollToTop()
                        }
                    }
                    .disabled(currentPage == 1) // disable if on page 1

                    Spacer()
                    
                    Text("\(currentPage)/\(pageCount)")
                    
                    Spacer()

                    Button("Next") {
                        currentPage += 1
                        performSearch()
                        scrollToTop()
                    }
                    .disabled(currentPage == pageCount)
                }
                .padding()
                .background(Color.white.opacity(0.3))
                    

            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Image("background")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.5)
                    .opacity(0.3))
        }
    }
    
    // Left column (even indices)
    var leftMovies: [SimpleMovie] {
        movies.enumerated().compactMap { index, element in
            index % 2 == 0 ? element : nil
        }
    }
    
    // Right column (odd indices)
    var rightMovies: [SimpleMovie] {
        movies.enumerated().compactMap { index, element in
            index % 2 != 0 ? element : nil
        }
    }
    
    // Scroll to the invisible anchor
    func scrollToTop() {
        withAnimation {
            scrollProxy?.scrollTo("top", anchor: .top)
        }
    }
    
    // Creates a column of movies
    func movieColumn(for movies: [SimpleMovie]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(movies) { movie in
                // Each movie is a clickable link and changes the view
                NavigationLink(destination: SelectionView(movieId: movie.id)) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Poster image
                        AsyncImage(url: URL(string: movie.poster)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 225)
                                .clipped()
                                .cornerRadius(10)
                        } placeholder: { // If the image fails, is loading, or does not exist
                            ZStack {
                                Color.gray
                                    .frame(width: 150, height: 225)
                                    .cornerRadius(10)
                                Text("No image found!")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                        
                        Text(movie.title)
                            .font(.headline)
                            .lineLimit(1) // Truncate long titles
                            .truncationMode(.tail)
                            .frame(width: 150, height: 20, alignment: .leading)

                    }
                }
            }
            
        }
        .padding()
    }

    
    func performSearch() {
        guard let url = URL(string: "https://omdbapi.com/?apikey=b40f46cb&s=\(searchText)&page=\(currentPage)") else {
            resultText = "Invalid URL"
            return
        }
        
        if !searchText.isEmpty && !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
            saveRecentSearches()
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in // Network request for url
            if let error = error { // catch errors
                DispatchQueue.main.async {
                    resultText = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else { // Get data with exception handling (guard)
                DispatchQueue.main.async {
                    resultText = "No data"
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], // Parse data as a dictionary
                   let descriptionArray = json["Search"] as? [[String: Any]] { // Get results with keyword "Search"
                    
                    let totalResults = json["totalResults"] as? String ?? "0" // Get results with keyboard "totalResults"
                    
                    if let total = Int(totalResults) { // Calculate total pages (10 items per page)
                        pageCount = (total + 9) / 10
                    } else {
                        pageCount = 1
                    }
                    
                    var loadedMovies: [SimpleMovie] = []

                    for item in descriptionArray { // Iterate over item in dict
                        let title = item["Title"] as? String ?? "No Title" // Retrieve title
                        let year = item["Year"] as? String ?? "0000" // Retrieve year
                        let posterURL = item["Poster"] as? String ?? "" // Retrieve poster
                        let id = item["imdbID"] as? String ?? "tt-------" // Retrieve IMDb ID

                        loadedMovies.append(SimpleMovie(id: id, title: title, year: year, poster: posterURL)) // Append to the array
                    }

                    DispatchQueue.main.async { // Set the 'movies' array in the main loop
                        self.movies = loadedMovies
                        self.resultText = "Found \(totalResults) movies."
                    }

                } else {
                    DispatchQueue.main.async { // catch invalid formatting (no results found)
                        resultText = "No results found! Please refine your search."
                    }
                }

            } catch {
                DispatchQueue.main.async { // catch parsing errors
                    resultText = "JSON parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()

                
    }
    
    func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }

    func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: "recentSearches") {
            recentSearches = saved
        }
    }
}

struct SelectionView: View {
    var movieId: String
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State private var movieDetails: MovieDetails? = nil
    @State private var resultText: String = "Loading..."
    @State private var isLoading: Bool = true

    var isLiked: Bool { // Check if movie is liked
        guard let movie = movieDetails else { return false }
        return watchlistManager.watchlist.contains(where: { $0.id == movie.id }) // Check if the watchlist contains the selected movie
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if let movie = movieDetails { // Iterate over selected movie details
                ScrollView {
                    VStack(spacing: 0) {
                            AsyncImage(url: URL(string: movie.poster)) { image in // Dynamically append image from URL
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: max(300, 600))
                                    .clipped()
                                    .overlay( // Add a white gradient for a seamless transition
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .white]),
                                            startPoint: .center,
                                            endPoint: .bottom
                                        )
                                    )
                            } placeholder: { // Before the image in rendered
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 600)
                            }
                            .frame(height: 600)

                        VStack(alignment: .leading, spacing: 16) {
                            // Title & Year
                            Text("\(movie.title) (\(movie.year))")
                                .font(.title)
                                .bold()
                            
                            // Like button
                            Button(action: {
                                let simple = SimpleMovie(
                                    id: movie.id,
                                    title: movie.title,
                                    year: movie.year,
                                    poster: movie.poster
                                )

                                if isLiked { // If it is already liked, unlike
                                    watchlistManager.remove(movie: simple)
                                } else {
                                    watchlistManager.add(movie: simple)
                                }
                            }) {
                                Label(isLiked ? "Liked" : "Like", systemImage: "heart.fill") // Like label with heart
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(isLiked ? Color.red : Color.red.opacity(0.1))
                                    .foregroundColor(isLiked ? .white : .red)
                                    .cornerRadius(10)
                            }

                            Text("Genre: \(movie.genre)")
                            Text("Rated: \(movie.rated)")
                            Text("Released: \(movie.released)")
                            Text("Runtime: \(movie.runtime)")
                            Text("IMDb Rating: \(movie.imdbRating)")

                            Text("Plot")
                                .font(.headline)
                            Text(movie.plot)

                            Group {
                                Text("Director: \(movie.director)")
                                Text("Writer: \(movie.writer)")
                                Text("Actors: \(movie.actors)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: 400) // Set a width
                    }
                }
                .ignoresSafeArea(edges: .top) // Let image go behind nav bar
            } else if isLoading {
                ProgressView(resultText)
                    .padding()
            } else {
                Text(resultText)
            }
        }
        .onAppear {
            getInfo()
        }
    }

    
    func getInfo() {
        guard let url = URL(string: "https://omdbapi.com/?apikey=b40f46cb&i=\(movieId)") else { // API request
            resultText = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in // Ensure data is reachable
            DispatchQueue.main.async {
                if let error = error {
                    resultText = "Error: \(error.localizedDescription)"
                    isLoading = false
                    return
                }
                
                guard let data = data else {
                    resultText = "No data"
                    isLoading = false
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(MovieDetails.self, from: data) // Decode JSON
                    self.movieDetails = decodedResponse // Update movieDetails with the decoded JSON data
                    self.resultText = "Success"
                } catch {
                    self.resultText = "Decoding error: \(error.localizedDescription)"
                }
                
                self.isLoading = false
            }
        }.resume()
    }
}


struct WatchlistView: View {
    @EnvironmentObject var watchlistManager: WatchlistManager

    var body: some View {
        NavigationView {

                if watchlistManager.watchlist.isEmpty {
                    // Centered message when empty
                    VStack {
                        Spacer()
                        Text("Add items to your watchlist to get started!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                            .shadow(radius: 5)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Image("background")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.5)
                        .opacity(0.3))
                } else {
                    // Show list when there are items
                        List {
                            ForEach(watchlistManager.watchlist) { movie in
                                NavigationLink(destination: SelectionView(movieId: movie.id)) {
                                    HStack {
                                        AsyncImage(url: URL(string: movie.poster)) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 75)
                                                .cornerRadius(5)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 50, height: 75)
                                                .cornerRadius(5)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(movie.title)
                                                .font(.headline)
                                            Text(movie.year)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                }
                            }
                        }
                }
        }
    }
}



struct AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("FilmFinder v1.0")
                            .font(.title)
                            .bold()
                    }
                    
                    Divider()
                    
                    Group {
                        Text("App Description")
                            .font(.headline)
                        Text("""
                        FilmFinder helps movie enthusiasts discover, search, and explore films across genres and platforms. Get detailed information and save your favorites for later.
                        """)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Developer Info")
                            .font(.headline)
                        Link("Bryce Krause", destination: URL(string: "https://www.github.com/brycekrause")!)
                        Link("Ganesh Jaishi", destination: URL(string: "https://www.github.com/ganesh-234")!)
                    }
                    
                    Divider()
                    
                    // Contact Information
                    Group {
                        Text("Contact")
                            .font(.headline)
                        
                        Text("""
                        Support Emails: 
                        krauba29@uwgb.edu
                        jaisgp30@uwgb.edu
                        """)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Team Members")
                            .font(.headline)
                        
                        Text("""
                        • Bryce Krause – SwiftUI Developer & UI/UX Designer  
                        • Ganesh Jaishi – SwiftUI Developer & UI/UX Designer  
                        """)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Acknowledgments")
                            .font(.headline)
                        
                        Text("""
                        FilmFinder was built using SwiftUI and integrates the OMDb API to quickly deliver movie data to users. This project was created as part of COMP SCI 292 at the University of Wisconsin–Green Bay (UWGB). Special thanks to our professor, Sayeda Farzana Aktar, for her guidance and support throughout the development process.
                        """)
                    }

                    Divider()
                    
                    Group {
                        Text("Legal")
                            .font(.headline)
                        
                        Text("NULL")
                        Text("NULL")
                        Text("NULL")
                    }
                }
                .padding()
                .navigationTitle("About")
            }
        }
    }
}

struct UserProfile {
    var profileUIImage: UIImage?
    var displayName: String
    var userBio: String
    var favoriteGenre: String
}

struct ProfileView: View {
    @State private var profile = UserProfile(
        profileUIImage: nil,
        displayName: "",
        userBio: "",
        favoriteGenre: ""
    )

    @State private var showingEditSheet = false
    @EnvironmentObject var watchlistManager: WatchlistManager
    private let fallbackRegion = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.009),
         span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
     )

     @State private var cameraPosition = MapCameraPosition.userLocation(
         fallback: .region(
             MKCoordinateRegion(
                 center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.009),
                 span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
             )
         )
     )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Group {
                        if let uiImage = profile.profileUIImage {
                            Image(uiImage: uiImage)
                                .resizable()
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                    }
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .padding(.top)

                    // Display Name
                    Text(profile.displayName.isEmpty ? "Unnamed" : profile.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    // Bio
                    if !profile.userBio.isEmpty {
                        Text(profile.userBio)
                            .font(.body)
                            .padding(.horizontal)
                    }

                    // Favorite Genre
                    if !profile.favoriteGenre.isEmpty {
                        Text("Favorite Genre: \(profile.favoriteGenre)")
                            .foregroundColor(.secondary)
                    }

                    // Watchlist Count
                    HStack {
                        Image(systemName: "film.fill")
                        Text("Watchlist: \(watchlistManager.watchlist.count) movies")
                    }
                    .font(.subheadline)
                    .padding(.top, 5)

                    // Edit Profile Button
                    Button {
                        showingEditSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    
                    Map(position: $cameraPosition)
                         .mapControls {
                             MapUserLocationButton() // Optional user location recenter button
                         }
                         .frame(height: 250)
                         .cornerRadius(12)
                         .padding()
                }
                .padding()
            }
            .navigationTitle(profile.displayName.isEmpty ? " Unnamed Profile" : profile.displayName + "'s Profile")
            .sheet(isPresented: $showingEditSheet) {
                EditProfileView(profile: $profile)
            }
            .onAppear {
                if profile.displayName.trimmingCharacters(in: .whitespaces).isEmpty {
                    showingEditSheet = true
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var favoriteGenre: String = ""

    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Profile Image Section
                Section {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let image = profile.profileUIImage {
                                Image(uiImage: image)
                                    .resizable()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                        }
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 4)

                        // Pencil Icon
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                                .offset(x: -5, y: -5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }

                Section(header: Text("Name")) {
                    TextField("Display Name", text: $displayName)
                }

                Section(header: Text("Bio")) {
                    TextField("Tell us about yourself", text: $bio)
                }

                Section(header: Text("Favorite Genre")) {
                    TextField("Favorite Genre", text: $favoriteGenre)
                }

                // MARK: - Save Button
                Section {
                    Button("Save") {
                        profile.displayName = displayName
                        profile.userBio = bio
                        profile.favoriteGenre = favoriteGenre
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                displayName = profile.displayName
                bio = profile.userBio
                favoriteGenre = profile.favoriteGenre
            }
            .onChange(of: selectedItem) {
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profile.profileUIImage = uiImage
                    }
                }
            }
        }
    }
}


struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Text ("Home")
                    Image (systemName: "house")
                }
            
            SearchView()
                .tabItem{
                    Text ("Search")
                    Image (systemName: "magnifyingglass")
                }
            
            WatchlistView()
                .tabItem{
                    Text ("Watchlist")
                    Image (systemName: "rectangle.split.3x3.fill")
                }
            ProfileView()
                .tabItem{
                    Text ("Profile")
                    Image (systemName: "person")
                }
            AboutView()
                .tabItem{
                    Text ("About")
                    Image (systemName: "questionmark")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WatchlistManager())
    }
}
