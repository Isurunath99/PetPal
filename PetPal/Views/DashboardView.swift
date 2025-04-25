//
//  Home.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//
import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @Binding var navPath: NavigationPath

    @State private var shopItems: [ShopItem] = []
    @State private var isLoadingShopItems = false
    @State private var errorMessageShopItem: String?
    
    @State private var vets: [Vet] = []
    @State private var isLoadingvets = false
    @State private var errorMessageVet: String?
    
    @State private var pets: [Pet] = []
    @State private var isLoadingPets = false
    @State private var errorMessagePet: String?
    
    @State private var reminders: [PetReminder] = []
    @State private var isLoadingReminders = false
    @State private var errorMessageReminders: String?
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Color(AppColors.primary)
                    .ignoresSafeArea()
                ZStack {
                    Color(AppColors.primary)
                        .ignoresSafeArea()
                    HStack {
                        Text("Hey Isuru,")
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = 3
                        }) {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            navPath.append(Route.profile)
                        }) {
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
            }
            .frame(height: 60)
            
            
            ScrollView {
                
                // Pets Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "My Pets", actionText: "+ Add pet") {
                        navPath.append(Route.addPet)
                    }
                    
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if isLoadingPets {
                                ProgressView()
                                    .padding()
                            } else if let errorMessagePet = errorMessagePet {
                                Text(errorMessagePet)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if pets.isEmpty {
                                Text("No pets available")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(pets) { pet in
                                    Button(action: {
                                        navPath.append(Route.pet(id: pet.id))
                                    }) {
                                        PetItemCardView(pet: pet)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Removes default button look
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
                
                // Reminders Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Upcoming Reminders", actionText: "View Reminders")  {
                        selectedTab = 3
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if isLoadingReminders {
                                ProgressView()
                                    .padding()
                            } else if let errorMessageReminders = errorMessageReminders {
                                Text(errorMessageReminders)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if reminders.isEmpty {
                                Text("No upcoming reminders")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(reminders) { reminder in
                                    PetReminderCardView(reminder: reminder)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
                
                // Vets Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Vets", actionText: " View Vets")  {
                        selectedTab = 4
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if isLoadingvets {
                                ProgressView()
                                    .padding()
                            } else if let errorMessageVet = errorMessageVet {
                                Text(errorMessageVet)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if vets.isEmpty {
                                Text("No Vets Found")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(vets) { item in
                                    VetItemCardView(vet: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                }
                .padding(.bottom, 20)
                
                // Shop Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Shop", actionText: " View Shop")  {
                        selectedTab = 1
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if isLoadingShopItems {
                                ProgressView()
                                    .padding()
                            } else if let errorMessageShopItem = errorMessageShopItem {
                                Text(errorMessageShopItem)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if shopItems.isEmpty {
                                Text("No shop items available")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(shopItems) { item in
                                    ShopItemCardView(item: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
        .task {
            await loadShopItems()
            await loadVets()
            await loadPets()
            await loadReminders()
        }
        
     }
    
    struct SectionHeader: View {
        let title: String
        let actionText: String
        var onActionTap: (() -> Void)? = nil

        var body: some View {
            HStack {
                HStack {
                    Image(systemName: title == "My Pets" ? "pawprint.fill" :
                            title == "Upcoming Reminders" ? "calendar" :
                            title == "Vets" ? "stethoscope" : "cart.fill")
                    .foregroundColor(.blue)
                    Text(title)
                        .font(.headline)
                }
                Spacer()
                if let onActionTap = onActionTap {
                    Button(action: onActionTap) {
                        Text(actionText)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                } else {
                    Text(actionText)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
        }
    }
    
    //load all shop items
    private func loadShopItems() async {
        isLoadingShopItems = true
        errorMessageShopItem = nil
        
        do {
            shopItems = try await FirestoreService.getShopItems()
        } catch {
            errorMessageShopItem = "Failed to load shop items: \(error.localizedDescription)"
            print("Error loading shop items: \(error)")
        }
        
        isLoadingShopItems = false
    }
    
    //load all vets
    private func loadVets() async {
        isLoadingvets = true
        errorMessageVet = nil
        
        do {
            vets = try await FirestoreService.getVets()
        } catch {
            errorMessageVet = "Failed to load vets: \(error.localizedDescription)"
            print("Error loading vets: \(error)")
        }
        
        isLoadingvets = false
    }
    
    //load all pets for the currently logged in user
    private func loadPets() async {
        isLoadingPets = true
        errorMessagePet = nil
        
        do {
            guard let userId = authManager.currentFirebaseUser?.uid else {
                errorMessagePet = "User not signed in."
                isLoadingPets = false
                return
            }

            pets = try await FirestoreService.getAllPets(userId: userId)
        } catch {
            errorMessagePet = "Failed to load pets: \(error.localizedDescription)"
            print("Error loading pets: \(error)")
        }
        
        isLoadingPets = false
    }
    
    //load all reminders for the currently logged in user
    private func loadReminders() async {
        isLoadingReminders = true
        errorMessageReminders = nil
        
        do {
            guard let userId = authManager.currentFirebaseUser?.uid else {
                errorMessageReminders = "User not signed in."
                isLoadingReminders = false
                return
            }
            
            reminders = try await FirestoreService.getNearestUpcomingReminders(userId: userId)
        } catch {
            errorMessageReminders = "Failed to load reminders: \(error.localizedDescription)"
            print("Error loading reminders: \(error)")
        }
        
        isLoadingReminders = false
    }
        
}
