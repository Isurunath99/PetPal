//
//  AddPetView.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/20/25.
//

import SwiftUI
import FirebaseAuth

struct AddPetView: View {
    @Binding var navPath: NavigationPath
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var petName: String = ""
    @State private var breedName: String = ""
    @State private var gender: String = ""
    @State private var age: String = ""
    @State private var color: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    @State private var pets: [Pet] = []
    @State private var isLoadingPets = false
    @State private var errorMessagePet: String?
    
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Color(AppColors.primary)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .padding(.trailing, 8)

                        Text("Add Pet")
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
            
            // Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Added Pets Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Added Pets")
                            .font(.headline)
                            .padding(.leading)
                        
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
                    
                    // Add New Pet Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Add New Pet")
                            .font(.headline)
                            .padding(.leading)
                        
                        // Image Selection
                        VStack {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                VStack {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 100, height: 100)
                                            
                                            Image(systemName: "plus")
                                                .font(.system(size: 30))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Text("Add Pet Photo")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.top, 5)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, 10)
                        
                        // Pet Information Fields
                        VStack(spacing: 15) {
                            // Pet Name
                            TextField("Pet Name", text: $petName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Breed Name
                            TextField("Breed Name", text: $breedName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Gender, Age, Color in a row
                            HStack(spacing: 10) {
                                TextField("Gender", text: $gender)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                TextField("Age", text: $age)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                TextField("Colour", text: $color)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            
                            // Height and Weight in a row
                            HStack(spacing: 10) {
                                TextField("Height", text: $height)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                TextField("Weight", text: $weight)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            
                            // Add Pet Button
                            Button(action: {
                                submitPet()
                            }) {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Add pet")
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                            .disabled(!isFormValid || isSubmitting)
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage.contains("success") ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("success") {
                        // Reset form on success
                        resetForm()
                        // Refresh pet list
                        Task {
                            await loadPets()
                        }
                    }
                }
            )
        }
        .task {
            await loadPets()
        }
    }
    
    private var isFormValid: Bool {
        return !petName.isEmpty &&
               !breedName.isEmpty &&
               !gender.isEmpty &&
               !age.isEmpty &&
               !color.isEmpty &&
               selectedImage != nil
        // Height and weight are optional
    }
    
    private func resetForm() {
        petName = ""
        breedName = ""
        gender = ""
        age = ""
        color = ""
        height = ""
        weight = ""
        selectedImage = nil
    }
    
    private func submitPet() {
        guard isFormValid, let image = selectedImage else { return }
        
        isSubmitting = true
        
        Task {
            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    throw NSError(domain: "AddPetView", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                
                // Create a new pet object
                let newPet = Pet(
                    id: UUID().uuidString,
                    name: petName,
                    image: "", // This will be replaced with the Cloudinary URL
                    breed: breedName,
                    gender: gender,
                    age: age,
                    color: color,
                    height: height.isEmpty ? "Not specified" : height,
                    weight: weight.isEmpty ? "Not specified" : weight
                )
                
                // Save pet with image
                _ = try await FirestoreService.createNewPet(userId: userId, pet: newPet, image: image)
                
                // Show success message
                alertMessage = "Pet added successfully!"
                showAlert = true
                
            } catch {
                // Show error message
                alertMessage = "Failed to add pet: \(error.localizedDescription)"
                showAlert = true
                print("Error adding pet: \(error)")
            }
            
            isSubmitting = false
        }
    }
    
    private func loadPets() async {
        isLoadingPets = true
        errorMessagePet = nil
        
        do {
            guard let userId = authManager.currentFirebaseUser?.uid else {
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddPetView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetView(navPath: .constant(NavigationPath()))
    }
}
