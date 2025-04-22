//
//  PetPalApp.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/30/25.
//


import SwiftUI
import Firebase

class AppState: ObservableObject {
    @Published var isInitialized = false
    @Published var isAuthenticated = false
}

// Setup Firebase main App struct
@main
struct PetPalApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var appState = AppState()
    @State private var selectedTab = 0
    
    init() {
        setupFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
                .environmentObject(authManager)
                .environmentObject(appState)
        }
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
}
