import Foundation
import FirebaseAuth
import Combine
import SwiftUI

class ReminderViewModel: ObservableObject {
    @Published var reminders: [PetReminder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let eventKitService = EventKitService()
    private var cancellables = Set<AnyCancellable>()
    
    // Get current user ID
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        // Request EventKit permissions early
        eventKitService.requestAccess()
    }
    
    func loadReminders() async {
        guard let userId = userId else {
            self.errorMessage = "User not logged in"
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let loadedReminders = try await FirestoreService.getAllReminders(userId: userId)
            
            DispatchQueue.main.async {
                self.reminders = loadedReminders.sorted(by: { $0.date < $1.date })
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load reminders: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func addReminder(petName: String, message: String, date: Date) async -> Bool {
        guard let userId = userId else {
            self.errorMessage = "User not logged in"
            return false
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // 1. Create reminder in EventKit
            let title = "Pet Reminder: \(petName)"
            let eventId = try await eventKitService.createReminder(
                title: title,
                notes: message,
                dueDate: date
            )
            
            // 2. Schedule local notification
            eventKitService.scheduleLocalNotification(
                title: title,
                body: message,
                date: date
            )
            
            // 3. Save to Firestore
            var newReminder = PetReminder(
                id: UUID().uuidString,
                petName: petName,
                message: message,
                date: date,
                eventIdentifier: eventId
            )
            
            try await FirestoreService.saveReminder(userId: userId, reminder: newReminder)
            
            // 4. Update local state
            await loadReminders()
            return true
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to create reminder: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
        }
    }
    
    func deleteReminder(_ reminder: PetReminder) async {
        guard let userId = userId, let reminderId = reminder.id else {
            self.errorMessage = "Cannot delete reminder: missing ID"
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            // 1. Delete from EventKit if we have an identifier
            if let eventId = reminder.eventIdentifier {
                try await eventKitService.deleteReminder(with: eventId)
            }
            
            // 2. Delete from Firestore
            try await FirestoreService.deleteReminder(userId: userId, reminderId: reminderId)
            
            // 3. Update local state
            await loadReminders()
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete reminder: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func markComplete(_ reminder: PetReminder, isCompleted: Bool) async {
        guard let userId = userId, let reminderId = reminder.id else {
            self.errorMessage = "Cannot update reminder: missing ID"
            return
        }
        
        do {
            try await FirestoreService.markReminderComplete(
                userId: userId,
                reminderId: reminderId,
                isCompleted: isCompleted
            )
            
            // Update local state
            await loadReminders()
            
        } catch {
            self.errorMessage = "Failed to update reminder: \(error.localizedDescription)"
        }
    }
    
    // Helper to format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
