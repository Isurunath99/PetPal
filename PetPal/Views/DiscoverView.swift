import SwiftUI
import MapKit
import CoreLocation

// Updated Location model to include vet clinics
struct Location: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinates: CLLocationCoordinate2D
    let type: LocationType
    let distance: Double? // Distance from user in kilometers
}

enum LocationType: String {
    case park = "park"
    case walkingTrack = "walking track"
    case vetClinic = "vet clinic"
}

// Location Manager to handle user location
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        // Start updating location if authorized
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        // Only need occasional updates for this app
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func requestLocation() {
        // Check current status and request accordingly
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}

// Updated ViewModel
class LocationViewModel: NSObject, ObservableObject {
    @Published var locations: [Location] = []
    @Published var selectedLocation: Location?
    @Published var nearbyLocations: [Location] = []
    
    private let vetClinics: [Location] = [
        Location(
            name: "Animal Care Clinic",
            address: "45 Main St, Kandy",
            coordinates: CLLocationCoordinate2D(latitude: 7.2950, longitude: 80.6350),
            type: .vetClinic,
            distance: nil
        ),
        Location(
            name: "Pet Health Center",
            address: "12 Lake Road, Kandy",
            coordinates: CLLocationCoordinate2D(latitude: 7.2920, longitude: 80.6320),
            type: .vetClinic,
            distance: nil
        ),
        Location(
            name: "Nuwara Eliya Vet Hospital",
            address: "8 Hill Street, Nuwara Eliya",
            coordinates: CLLocationCoordinate2D(latitude: 6.9720, longitude: 80.7730),
            type: .vetClinic,
            distance: nil
        ),
        Location(
            name: "Galle Pet Care",
            address: "3 Fort Road, Galle",
            coordinates: CLLocationCoordinate2D(latitude: 6.0290, longitude: 80.2160),
            type: .vetClinic,
            distance: nil
        ),
        Location(
            name: "Polgolla Animal Hospital",
            address: "22 Lake View, Polgolla",
            coordinates: CLLocationCoordinate2D(latitude: 7.9410, longitude: 81.0190),
            type: .vetClinic,
            distance: nil
        )
    ]
    
    private let petFriendlyLocations: [Location] = [
        Location(
            name: "Walking track polgolla",
            address: "Polgolla",
            coordinates: CLLocationCoordinate2D(latitude: 7.9403, longitude: 81.0188),
            type: .walkingTrack,
            distance: nil
        ),
        Location(
            name: "E.L Senanayaka park",
            address: "Kandy city",
            coordinates: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337),
            type: .park,
            distance: nil
        ),
        Location(
            name: "Victoria Park",
            address: "Nuwara Eliya",
            coordinates: CLLocationCoordinate2D(latitude: 6.9697, longitude: 80.7716),
            type: .park,
            distance: nil
        ),
        Location(
            name: "Galle Fort Walking Track",
            address: "Galle",
            coordinates: CLLocationCoordinate2D(latitude: 6.0282, longitude: 80.2168),
            type: .walkingTrack,
            distance: nil
        ),
        Location(
            name: "Kandy Lake Walking Path",
            address: "Kandy",
            coordinates: CLLocationCoordinate2D(latitude: 7.2930, longitude: 80.6425),
            type: .walkingTrack,
            distance: nil
        )
    ]
    
    override init() {
        super.init()
        locations = petFriendlyLocations + vetClinics
    }
    
    func updateLocationsDistance(from userLocation: CLLocation) {
        var updatedLocations: [Location] = []
        
        for location in locations {
            let locationCoordinate = CLLocation(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
            let distance = userLocation.distance(from: locationCoordinate) / 1000 // Convert to kilometers
            
            let updatedLocation = Location(
                name: location.name,
                address: location.address,
                coordinates: location.coordinates,
                type: location.type,
                distance: distance
            )
            
            updatedLocations.append(updatedLocation)
        }
        
        self.locations = updatedLocations
        updateNearbyLocations()
    }
    
    func updateNearbyLocations() {
        // Filter pet friendly locations by nearest to user (within 50km to ensure we have results)
        let nearbyPetFriendly = locations
            .filter { $0.type == .park || $0.type == .walkingTrack }
            .filter { $0.distance != nil }
            .sorted { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
            .prefix(5)
        
        // Filter vet clinics by nearest to user (within 50km to ensure we have results)
        let nearbyVets = locations
            .filter { $0.type == .vetClinic }
            .filter { $0.distance != nil }
            .sorted { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
            .prefix(5)
        
        nearbyLocations = Array(nearbyPetFriendly) + Array(nearbyVets)
    }
    
    func getNearbyPetFriendly() -> [Location] {
        return nearbyLocations.filter { $0.type == .park || $0.type == .walkingTrack }
    }
    
    func getNearbyVetClinics() -> [Location] {
        return nearbyLocations.filter { $0.type == .vetClinic }
    }
}

// Custom Pin View
struct LocationPin: View {
    let location: Location
    
    var body: some View {
        ZStack {
            Circle()
                .fill(pinColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: pinIcon)
                        .foregroundColor(.white)
                )
                .shadow(radius: 2)
        }
    }
    
    private var pinColor: Color {
        switch location.type {
        case .park:
            return .green
        case .walkingTrack:
            return .blue
        case .vetClinic:
            return .red
        }
    }
    
    private var pinIcon: String {
        switch location.type {
        case .park:
            return "leaf.fill"
        case .walkingTrack:
            return "figure.walk"
        case .vetClinic:
            return "cross.case.fill"
        }
    }
}

// Feature Card Component
struct FeatureCard: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    ZStack {
                        Image(systemName: cardIcon)
                            .font(.system(size: 32))
                            .foregroundColor(cardIconColor)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if let distance = location.distance {
                                    Text(String(format: "%.1f km", distance))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(4)
                        }
                    }
                )
                .cornerRadius(8, corners: [.topLeft, .topRight])
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "mappin")
                        .font(.caption)
                    Text(location.address)
                        .font(.caption)
                }
                
                if location.type != .vetClinic {
                    HStack {
                        Image(systemName: "360.circle")
                            .font(.caption)
                        Text("Click here for 360 view")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                } else {
                    HStack {
                        Image(systemName: "phone")
                            .font(.caption)
                        Text("Contact")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2)
        .frame(width: 200)
    }
    
    private var cardIcon: String {
        switch location.type {
        case .park:
            return "leaf.fill"
        case .walkingTrack:
            return "figure.walk"
        case .vetClinic:
            return "cross.case.fill"
        }
    }
    
    private var cardIconColor: Color {
        switch location.type {
        case .park:
            return .green
        case .walkingTrack:
            return .blue
        case .vetClinic:
            return .red
        }
    }
}

// Simplified WeatherManager for testing
class SimpleWeatherManager: ObservableObject {
    @Published var forecasts: [DayForecast] = []
    @Published var isLoading: Bool = true
    
    init() {
        // Load sample data and simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.loadSampleForecasts()
            self.isLoading = false
        }
    }
    
    private func loadSampleForecasts() {
        let today = Date()
        let calendar = Calendar.current
        
        forecasts = [
            DayForecast(
                date: today,
                dayName: "Today",
                temperature: "30°",
                high: "32°",
                low: "24°",
                condition: "Sunny",
                conditionIcon: "sun.max.fill"
            ),
            DayForecast(
                date: calendar.date(byAdding: .day, value: 1, to: today)!,
                dayName: "Tomorrow",
                temperature: "28°",
                high: "30°",
                low: "23°",
                condition: "Partly Cloudy",
                conditionIcon: "cloud.sun.fill"
            ),
            DayForecast(
                date: calendar.date(byAdding: .day, value: 2, to: today)!,
                dayName: "Wed",
                temperature: "25°",
                high: "27°",
                low: "22°",
                condition: "Light Rain",
                conditionIcon: "cloud.rain.fill"
            ),
            DayForecast(
                date: calendar.date(byAdding: .day, value: 3, to: today)!,
                dayName: "Thu",
                temperature: "24°",
                high: "26°",
                low: "21°",
                condition: "Heavy Rain",
                conditionIcon: "cloud.heavyrain.fill"
            ),
            DayForecast(
                date: calendar.date(byAdding: .day, value: 4, to: today)!,
                dayName: "Fri",
                temperature: "29°",
                high: "31°",
                low: "24°",
                condition: "Sunny",
                conditionIcon: "sun.max.fill"
            )
        ]
    }
}

// Updated Main Discover View
struct DiscoverView: View {
    @Binding var navPath: NavigationPath
    @StateObject private var viewModel = LocationViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = SimpleWeatherManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showLocationPermissionAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Color.blue.ignoresSafeArea(edges: .top)
                HStack {
                    Button(action: {
                        navPath.removeLast()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Discover")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title3)
                    Spacer()
                    Button(action: {
                        if locationManager.authorizationStatus == .denied {
                            showLocationPermissionAlert = true
                        } else {
                            locationManager.requestLocation()
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .frame(height: 44)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Location permission alert
                    if locationManager.authorizationStatus == .denied {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.red)
                            Text("Location services are disabled. Please enable them in Settings to see nearby locations.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Pet friendly locations section
                    VStack(alignment: .leading) {
                        Text("Pet friendly locations near you")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.getNearbyPetFriendly().isEmpty {
                            HStack {
                                Spacer()
                                if locationManager.userLocation == nil {
                                    if locationManager.authorizationStatus == .notDetermined ||
                                       locationManager.authorizationStatus == .authorizedWhenInUse ||
                                       locationManager.authorizationStatus == .authorizedAlways {
                                        // Show loading state if we're expecting to get location
                                        ProgressView()
                                            .padding(.vertical)
                                    } else {
                                        // Show instruction if location is not authorized
                                        Text("Enable location services to find nearby pet-friendly locations")
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                } else {
                                    // User location known, but no nearby pet places found
                                    Text("No pet-friendly places found nearby")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                                Spacer()
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.getNearbyPetFriendly()) { location in
                                        FeatureCard(location: location)
                                            .onTapGesture {
                                                viewModel.selectedLocation = location
                                                withAnimation {
                                                    region.center = location.coordinates
                                                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    
                    // Map section with increased height
                    VStack(alignment: .leading) {
                        Text("Nearby Veterinarian Clinics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topTrailing) {
                            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.locations) { location in
                                MapAnnotation(coordinate: location.coordinates) {
                                    LocationPin(location: location)
                                        .onTapGesture {
                                            viewModel.selectedLocation = location
                                        }
                                }
                            }
                            .frame(height: 350) // Increased map height
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Map controls
                            VStack {
                                Button(action: {
                                    if let userLocation = locationManager.userLocation {
                                        withAnimation {
                                            region.center = CLLocationCoordinate2D(
                                                latitude: userLocation.coordinate.latitude,
                                                longitude: userLocation.coordinate.longitude
                                            )
                                            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        }
                                    } else if locationManager.authorizationStatus == .denied {
                                        showLocationPermissionAlert = true
                                    } else {
                                        locationManager.requestLocation()
                                    }
                                }) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                        .padding(8)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        region.span = MKCoordinateSpan(
                                            latitudeDelta: max(0.01, region.span.latitudeDelta * 0.7),
                                            longitudeDelta: max(0.01, region.span.longitudeDelta * 0.7)
                                        )
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                        .padding(8)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        region.span = MKCoordinateSpan(
                                            latitudeDelta: min(180, region.span.latitudeDelta * 1.3),
                                            longitudeDelta: min(180, region.span.longitudeDelta * 1.3)
                                        )
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                        .padding(8)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                            }
                            .padding(8)
                        }
                        
                        // Legend
                        HStack(spacing: 16) {
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 10, height: 10)
                                Text("Parks")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 10, height: 10)
                                Text("Walking Tracks")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                Text("Vet Clinics")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Nearby vet clinics cards
                        Text("Nearest Vet Clinics")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        if viewModel.getNearbyVetClinics().isEmpty {
                            HStack {
                                Spacer()
                                if locationManager.userLocation == nil {
                                    if locationManager.authorizationStatus == .notDetermined ||
                                       locationManager.authorizationStatus == .authorizedWhenInUse ||
                                       locationManager.authorizationStatus == .authorizedAlways {
                                        // Show loading state if we're expecting to get location
                                        ProgressView()
                                            .padding(.vertical)
                                    } else {
                                        // Show instruction if location is not authorized
                                        Text("Enable location services to find nearby vet clinics")
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                } else {
                                    // User location known, but no nearby vet clinics found
                                    Text("No vet clinics found nearby")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                                Spacer()
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.getNearbyVetClinics()) { clinic in
                                        FeatureCard(location: clinic)
                                            .onTapGesture {
                                                viewModel.selectedLocation = clinic
                                                withAnimation {
                                                    region.center = clinic.coordinates
                                                    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    // Weather forecast section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Weather Forecast")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "424242"))

                        if weatherManager.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                                    .padding()
                                Spacer()
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(weatherManager.forecasts) { forecast in
                                        DayForecastCard(forecast: forecast)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Request location when view appears
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            if let location = newLocation {
                // Update map region to user location
                withAnimation {
                    region.center = CLLocationCoordinate2D(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
                
                // Update distances and find nearby locations
                viewModel.updateLocationsDistance(from: location)
            }
        }
        .alert(isPresented: $showLocationPermissionAlert) {
            Alert(
                title: Text("Location Access"),
                message: Text("Please allow location access to see pet-friendly locations near you"),
                primaryButton: .default(Text("Open Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .overlay(
            Group {
                if let selectedLocation = viewModel.selectedLocation {
                    VStack {
                        Spacer()
                        HStack {
                            LocationPin(location: selectedLocation)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedLocation.name)
                                    .font(.subheadline)
                                    .bold()
                                
                                Text(selectedLocation.address)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                if let distance = selectedLocation.distance {
                                    Text(String(format: "%.1f km away", distance))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedLocation.type == .vetClinic {
                                Button(action: {
                                    // This would call the clinic in a real app
                                }) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.green)
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 8)
                            }
                            
                            Button(action: {
                                viewModel.selectedLocation = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
            }
        )
    }
    
    struct DayForecastCard: View {
        let forecast: DayForecast
        
        var body: some View {
            VStack(alignment: .center, spacing: 12) {
                // Day name
                Text(forecast.dayName)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "424242"))
                
                // Weather icon
                Image(systemName: forecast.conditionIcon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "1E88E5"))
                    .padding(.vertical, 8)
                
                // Temperature
                Text(forecast.temperature)
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "1E88E5"))
                
                // High/Low
                HStack(spacing: 8) {
                    VStack(alignment: .center) {
                        Text("High")
                            .font(.caption)
                            .foregroundColor(Color(hex: "757575"))
                        Text(forecast.high)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "FF5722"))
                    }
                    
                    Rectangle()
                        .frame(width: 1, height: 24)
                        .foregroundColor(Color(hex: "E0E0E0"))
                    
                    VStack(alignment: .center) {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(Color(hex: "757575"))
                        Text(forecast.low)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "2196F3"))
                    }
                }
                
                // Condition
                Text(forecast.condition)
                    .font(.caption)
                    .foregroundColor(Color(hex: "616161"))
                    .multilineTextAlignment(.center)
                    .frame(height: 32)
            }
            .frame(width: 120, height: 200)
            .padding()
            .background(Color(hex: "F5F5F5"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
