//
//  FirestoreService.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import UIKit

// CloudinaryService for handling image uploads
struct CloudinaryService {
    // Your Cloudinary configuration
    private static let cloudName = "dh1i9wfcc" // cloud name
    private static let uploadPreset = "pet_pal_preset" // upload preset
    private static let apiKey = "545967256575868" // cloud api key
    
    static func uploadImage(_ image: UIImage) async throws -> String {
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "CloudinaryService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        // Create the Cloudinary upload URL
        let uploadURL = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
        
        // Create URL request
        var request = URLRequest(url: URL(string: uploadURL)!)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create body
        var body = Data()
        
        // Add upload preset parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // Add file parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set request body
        request.httpBody = body
        
        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "CloudinaryService", code: 500, userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw NSError(domain: "CloudinaryService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
        }
        
        // Parse response JSON
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let secureUrl = json["secure_url"] as? String else {
            throw NSError(domain: "CloudinaryService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL from response"])
        }
        
        return secureUrl
    }
}

struct FirestoreService {
    
    private static let db = Firestore.firestore()
    
    static func saveUserData(uid: String, data: [String: Any]) async throws {
        try await db.collection("users").document(uid).setData(data)
    }
    
    static func getUserData(uid: String) async throws -> [String: Any] {
          let db = Firestore.firestore()
          let document = try await db.collection("users").document(uid).getDocument()
          
          guard let data = document.data() else {
              throw AuthError.notAuthenticated
          }
          
          return data
      }
    
    static func getShopItems() async throws -> [ShopItem] {
        let snapshot = try await db.collection("shop").getDocuments()
        
        var shopItems: [ShopItem] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            guard let name = data["name"] as? String,
                  let quantity = data["quantity"] as? String,
                  let price = data["price"] as? Double,
                  let link = data["link"] as? String,
                  let image = data["image"] as? String else {
                print("Error parsing shop item document: \(document.documentID)")
                continue
            }
            
            let shopItem = ShopItem(
                name: name,
                quantity: quantity,
                price: price,
                link: link,
                image: image
            )
            
            shopItems.append(shopItem)
        }
        
        return shopItems
    }
    
    static func getVets() async throws -> [Vet] {
        let snapshot = try await db.collection("vet").getDocuments()
        
        var vets: [Vet] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            guard let name = data["name"] as? String,
                  let specialty = data["specialty"] as? String,
                  let hours = data["hours"] as? String,
                  let phone = data["phone"] as? String,
                  let location = data["location"] as? String,
                  let image = data["image"] as? String else {
                print("Error parsing shop item document: \(document.documentID)")
                continue
            }
            
            let vet = Vet(
                name: name,
                specialty: specialty,
                hours: hours,
                phone: phone,
                location: location,
                image: image
            )
            
            vets.append(vet)
        }
        
        return vets
    }
    
    static func getAllPets(userId: String) async throws -> [Pet] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("pets")
            .getDocuments()
        
        return snapshot.documents.compactMap{document in
          try? document.data(as: Pet.self)
        }
    }
    
    static func getPetDetailsById(userId: String, petId: String) async throws -> Pet {
        let document = try await db.collection("users")
            .document(userId)
            .collection("pets")
            .document(petId)
            .getDocument()

        guard document.exists else {
            throw NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Pet not found"])
        }

        do {
            let pet = try document.data(as: Pet.self)
            return pet
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode to Pet"])
        }
    }
    
    static func createNewPet(userId: String, pet: Pet, image: UIImage) async throws -> Pet {
        // 1. Upload image to Cloudinary
        let imageUrl = try await CloudinaryService.uploadImage(image)
        
        // 2. Create a pet object with the image URL
        var newPet = pet
        newPet.image = imageUrl
        newPet.id = UUID().uuidString // Generate a unique ID if not already set
        
        // 3. Save pet to Firestore
        try await db.collection("users")
            .document(userId)
            .collection("pets")
            .document(newPet.id)
            .setData(from: newPet)
        
        return newPet
    }
    
    static func saveReminder(userId: String, reminder: PetReminder) async throws {
          var data = reminder.dictionary
          
          // If no ID exists, create one
          let reminderId = reminder.id ?? UUID().uuidString
          
          try await db.collection("users")
              .document(userId)
              .collection("reminders")
              .document(reminderId)
              .setData(data)
      }
      
      static func getAllReminders(userId: String) async throws -> [PetReminder] {
          let snapshot = try await db.collection("users")
              .document(userId)
              .collection("reminders")
              .order(by: "date")
              .getDocuments()
          
          return snapshot.documents.compactMap { document in
              try? document.data(as: PetReminder.self)
          }
      }
    
    static func getNearestUpcomingReminders(userId: String) async throws -> [PetReminder] {
        let now = Date()
        
        // Calculate date one week from now
        let oneWeekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? Date()
        
        // Without requiring a composite index (simpler query)
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("reminders")
            .order(by: "date")
            .getDocuments()
        
        // Filter in memory to get upcoming reminders for the next week
        return snapshot.documents.compactMap { document in
            guard let reminder = try? document.data(as: PetReminder.self) else {
                return nil
            }
            
            // Only return non-completed reminders for the next week
            if reminder.date > now && reminder.date <= oneWeekFromNow && !reminder.isCompleted {
                return reminder
            }
            return nil
        }
    }
      
      static func getUpcomingReminders(userId: String) async throws -> [PetReminder] {
          let now = Date()
          
          let snapshot = try await db.collection("users")
              .document(userId)
              .collection("reminders")
              .whereField("date", isGreaterThan: now)
              .whereField("isCompleted", isEqualTo: false)
              .order(by: "date")
              .getDocuments()
          
          return snapshot.documents.compactMap { document in
              try? document.data(as: PetReminder.self)
          }
      }
      
      static func deleteReminder(userId: String, reminderId: String) async throws {
          try await db.collection("users")
              .document(userId)
              .collection("reminders")
              .document(reminderId)
              .delete()
      }
      
      static func markReminderComplete(userId: String, reminderId: String, isCompleted: Bool) async throws {
          try await db.collection("users")
              .document(userId)
              .collection("reminders")
              .document(reminderId)
              .updateData(["isCompleted": isCompleted])
      }

}
