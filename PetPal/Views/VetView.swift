//
//  Vet.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//

import SwiftUI


struct VetView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var navPath: NavigationPath
    
    @State private var vets: [Vet] = []
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
                        
                        Text("View Vet")
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
                } else if vets.isEmpty {
                    Text("No vets found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(vets) { item in
                            VetCard(item: item)
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
            await loadVets()
        }
    }
    
    private func loadVets() async {
        isLoading = true
        errorMessage = nil
        
        do {
            vets = try await FirestoreService.getVets()
        } catch {
            errorMessage = "Failed to load Vets: \(error.localizedDescription)"
            print("Error loading vets: \(error)")
        }
        
        isLoading = false
    }
}

struct VetView_Previews: PreviewProvider {
    static var previews: some View {
        VetView(navPath: .constant(NavigationPath()))
    }
}
