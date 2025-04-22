//
//  ContentView.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/30/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int
    @State private var navPath = NavigationPath()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                // User is authenticated - show main app with tab bar
                AuthenticatedView(selectedTab: $selectedTab, navPath: $navPath)
            } else {
                // User is not authenticated - show sign in flow
                UnauthenticatedView(navPath: $navPath, selectedTab: $selectedTab)
            }
        }
        .onReceive(authManager.$isAuthenticated) { isAuthenticated in
            // Reset navigation when auth state changes
            navPath = NavigationPath()
            
            // Reset to home tab when user signs in
            if isAuthenticated {
                selectedTab = 0 // Home tab
            }
        }
    }
}

// Extract the authenticated view to its own struct
struct AuthenticatedView: View {
    @Binding var selectedTab: Int
    @Binding var navPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    DashboardView(navPath: $navPath, selectedTab: $selectedTab)
                        .tag(0)

                    ShopView(navPath: $navPath, selectedTab: $selectedTab)
                        .tag(1)

                    DiscoverView(navPath: $navPath, selectedTab: $selectedTab)
                        .tag(2)

                    ReminderListView(selectedTab: $selectedTab, navPath: $navPath)
                        .tag(3)

                    VetView(navPath: $navPath, selectedTab: $selectedTab)
                        .tag(4)
                }
                .edgesIgnoringSafeArea(.bottom)
                
                CustomTabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .profile:
                    ProfileView(navPath: $navPath)
                case .signIn, .signUp:
                    EmptyView()
                case .pet(let id):
                    PetProfileView(petId: id, navPath: $navPath)
                case .addPet:
                    AddPetView(navPath: $navPath)
                }
            }
        }
    }
}

// Extract the unauthenticated view to its own struct
struct UnauthenticatedView: View {
    @Binding var navPath: NavigationPath
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack(path: $navPath) {
            SignInView(navPath: $navPath, selectedTab: $selectedTab)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .signUp:
                        SignUpView(navPath: $navPath)
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

// Custom tab bar view
struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: getIconName(for: index))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == index ? Color(AppColors.primary) : Color(.blue))
                        
                        Text(getTabName(for: index))
                            .font(.system(size: 10))
                            .foregroundColor(selectedTab == index ? Color(AppColors.primary) : Color(.gray))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(
            Color(.white)
                .clipShape(CustomShape())
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: -2)
        )
    }

    func getIconName(for index: Int) -> String {
        switch index {
        case 0: return "house"
        case 1: return "cart"
        case 2: return "location.north.circle"
        case 3: return "calendar"
        case 4: return "stethoscope"
        default: return "questionmark"
        }
    }

    func getTabName(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Shop"
        case 2: return "Discover"
        case 3: return "Reminder"
        case 4: return "Vet"
        default: return ""
        }
    }
}

struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 30, height: 30)
        )
        return Path(path.cgPath)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a constant binding for the preview
        ContentView(selectedTab: .constant(0))
            .environmentObject(AuthManager())
    }
}
