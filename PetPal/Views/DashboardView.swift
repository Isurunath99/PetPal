//
//  Home.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//

import SwiftUI

struct DashboardView: View {
    
    let reminders = [
        Reminder(date: Date(timeIntervalSinceNow: 60*60*24*2), time: Date(), pet: "Snowy", task: "Get Rabies Vaccine"),
        Reminder(date: Date(timeIntervalSinceNow: 60*60*24*4), time: Date(), pet: "Shadow", task: "Take to the dermatologist")
    ]
    
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
                                Image(systemName: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
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
                        SectionHeader(title: "Upcoming Reminders", actionText: "+ Add reminder")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(reminders) { reminder in
                                    ReminderItemCardView(reminder: reminder)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Vets Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Vets", actionText: "+ Add vet")
                        
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
                        SectionHeader(title: "Shop", actionText: "+ Add item")
                        
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
            .task {
                await loadShopItems()
                await loadVets()
                await loadPets()
            }
        }
    
    struct SectionHeader: View {
        let title: String
        let actionText: String
        var onActionTap: (() -> Void)? = nil // Action handler when button is tapped

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
    
    private func loadPets() async {
        isLoadingPets = true
        errorMessagePet = nil
        
        do {
            guard let userId = authManager.currentUser?.uid else {
                fatalError("No user signed in")
            }
            pets = try await FirestoreService.getAllPets(userId: userId)
        } catch {
            errorMessagePet = "Failed to load pets: \(error.localizedDescription)"
            print("Error loading pets: \(error)")
        }
        
        isLoadingPets = false
    }
        
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(navPath: .constant(NavigationPath()))
    }
}
