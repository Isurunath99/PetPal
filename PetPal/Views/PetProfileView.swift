//
//  PetProfileView.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct PetProfileView: View {
    let petId: String
    @Binding var navPath: NavigationPath
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager

    @State private var pet: Pet? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Color(AppColors.primary)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Button(action: {
                            if navPath.count > 0 {
                                navPath.removeLast()
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .padding(.trailing, 8)

                        Text("Pet Profile")
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
            .padding(.bottom, 20)

            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let pet = pet {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Profile Image
                        VStack(spacing: 12) {
                            AsyncImage(url: URL(string: pet.image)) { phase in
                                  switch phase {
                                  case .empty:
                                      ProgressView()
                                          .frame(width: 120, height: 120)
                                  case .success(let image):
                                      image
                                          .resizable()
                                          .aspectRatio(contentMode: .fill)
                                          .frame(width: 120, height: 120)
                                          .clipShape(RoundedRectangle(cornerRadius: 12))
                                  case .failure:
                                      Image(systemName: "pawprint.circle.fill")
                                          .resizable()
                                          .aspectRatio(contentMode: .fit)
                                          .frame(width: 60, height: 60)
                                          .foregroundColor(.gray)
                                          .frame(width: 120, height: 120)
                                  @unknown default:
                                      Image(systemName: "pawprint.circle.fill")
                                          .resizable()
                                          .aspectRatio(contentMode: .fit)
                                          .frame(width: 60, height: 60)
                                          .foregroundColor(.gray)
                                          .frame(width: 120, height: 120)
                                  }
                              }
                              .shadow(radius: 3)

                            Text(pet.name)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)

                        // About Pet Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "pawprint.circle.fill")
                                    .foregroundColor(.blue)
                                Text("About \(pet.name)")
                                    .font(.headline)
                            }

                            VStack(spacing: 0) {
                                PetInfoRow(label: "Age", value: pet.age)
                                Divider()
                                PetInfoRow(label: "Weight", value: pet.weight)
                                Divider()
                                PetInfoRow(label: "Height", value: pet.height)
                                Divider()
                                PetInfoRow(label: "Gender", value: pet.gender)
                                Divider()
                                PetInfoRow(label: "Breed", value: pet.breed)
                                Divider()
                                PetInfoRow(label: "Color", value: pet.color)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                        }

                        // Status Section
                               VStack(alignment: .leading, spacing: 16) {
                                   HStack {
                                       Image(systemName: "heart.circle.fill")
                                           .foregroundColor(.blue)
                                       Text("\(pet.name)'s Status")
                                           .font(.headline)
                                   }
                                   
                                   // Vaccinations
                                   VStack(alignment: .leading, spacing: 10) {
                                       Text("Vaccinations")
                                           .font(.subheadline)
                                           .foregroundColor(.gray)
                                       
                                       ScrollView(.horizontal, showsIndicators: false) {
                                           HStack(spacing: 15) {
                                               VaccinationCard(
                                                   name: "Rabies vaccination",
                                                   date: "24th Jan 2025",
                                                   doctor: "Dr.Sivakumar"
                                               )
                                               
                                               VaccinationCard(
                                                   name: "Calcivirus",
                                                   date: "10th Jun 2024",
                                                   doctor: "Dr.Paul"
                                               )
                                               
                                               VaccinationCard(
                                                   name: "Rabies vaccination",
                                                   date: "24th Jan 2025",
                                                   doctor: "Dr.Sivakumar"
                                               )
                                               
                                               VaccinationCard(
                                                   name: "Calcivirus",
                                                   date: "10th Jun 2024",
                                                   doctor: "Dr.Paul"
                                               )
                                           }
                                       }
                                   }
                                   
                                   // Allergies
                                   VStack(alignment: .leading, spacing: 10) {
                                       Text("Allergies")
                                           .font(.subheadline)
                                           .foregroundColor(.gray)
                                       
                                       ScrollView(.horizontal, showsIndicators: false) {
                                           HStack(spacing: 15) {
                                               AllergyCard(
                                                   type: "Skin Allergies",
                                                   details: "Rash under stomach",
                                                   doctor: "Dr.Pooja"
                                               )
                                               
                                               AllergyCard(
                                                   type: "Food allergies",
                                                   details: "allergic to prawns",
                                                   doctor: "Dr.Paul"
                                               )
                                               
                                               AllergyCard(
                                                   type: "Skin Allergies",
                                                   details: "Rash under stomach",
                                                   doctor: "Dr.Pooja"
                                               )
                                               
                                               AllergyCard(
                                                   type: "Food allergies",
                                                   details: "allergic to prawns",
                                                   doctor: "Dr.Paul"
                                               )
                                           }
                                       }
                                   }
                               }
                               .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadPetDetails()
        }
    }
    
    private func loadPetDetails() async {
          isLoading = true
          errorMessage = nil
          do {
              guard let userId = authManager.currentFirebaseUser?.uid else {
                  fatalError("No user signed in")
              }
              pet = try await FirestoreService.getPetDetailsById(userId: userId, petId: petId)
          } catch {
              errorMessage = "Failed to load Pet details: \(error.localizedDescription)"
          }
          isLoading = false
      }
}

struct PetInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct VaccinationCard: View {
    let name: String
    let date: String
    let doctor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(doctor)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(width: 150)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3)
    }
}

struct AllergyCard: View {
    let type: String
    let details: String
    let doctor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(type)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(details)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(doctor)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(width: 150)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3)
    }
}
