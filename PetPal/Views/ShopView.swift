//
//  ShopView.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var navPath: NavigationPath
    
    @State private var shopItems: [ShopItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Color(AppColors.primary)
                    .ignoresSafeArea(edges: .top)
                VStack {
                    HStack {
                        Button(action: {
                            navPath.removeLast()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .padding(.trailing, 8)
                        
                        Text("Shop")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .padding(.horizontal, 16)
            }
            .frame(height: 40)
            
            // Content Scroll
            ScrollView(.vertical, showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if shopItems.isEmpty {
                    Text("No shop items available")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(shopItems) { item in
                            ShopCard(item: item)
                        }
                    }
                }
             
            }
            .padding(.top, 16)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .task {
            await loadShopItems()
        }
    }
    
    private func loadShopItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            shopItems = try await FirestoreService.getShopItems()
        } catch {
            errorMessage = "Failed to load shop items: \(error.localizedDescription)"
            print("Error loading shop items: \(error)")
        }
        
        isLoading = false
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView(navPath: .constant(NavigationPath()))
    }
}
