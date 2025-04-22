import Foundation
import EventKit
import UIKit

class EventKitService {
    private let eventStore = EKEventStore()
    private var isAccessGranted = false
    
    init() {
        requestAccess()
    }
    
    func requestAccess() {
        // Request access to reminders
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { [weak self] granted, error in
                if granted {
                    self?.isAccessGranted = true
                } else if let error = error {
                    print("Failed to request access to reminders: \(error.localizedDescription)")
                }
            }
        } else {
            // Fallback on earlier versions
            eventStore.requestAccess(to: .reminder) { [weak self] granted, error in
                if granted {
                    self?.isAccessGranted = true
                } else if let error = error {
                    print("Failed to request access to reminders: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createReminder(title: String, notes: String, dueDate: Date) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            if !isAccessGranted {
                // Request access again if not granted
                if #available(iOS 17.0, *) {
                    eventStore.requestFullAccessToReminders { granted, error in
                        if granted {
                            self.isAccessGranted = true
                            self.createNewReminder(title: title, notes: notes, dueDate: dueDate) { result in
                                continuation.resume(with: result)
                            }
                        } else {
                            continuation.resume(throwing: NSError(domain: "EventKitService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Permission denied for reminders"]))
                        }
                    }
                } else {
                    eventStore.requestAccess(to: .reminder) { granted, error in
                        if granted {
                            self.isAccessGranted = true
                            self.createNewReminder(title: title, notes: notes, dueDate: dueDate) { result in
                                continuation.resume(with: result)
                            }
                        } else {
                            continuation.resume(throwing: NSError(domain: "EventKitService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Permission denied for reminders"]))
                        }
                    }
                }
            } else {
                self.createNewReminder(title: title, notes: notes, dueDate: dueDate) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }
    
    private func createNewReminder(title: String, notes: String, dueDate: Date, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a new reminder
        let reminder = EKReminder(eventStore: eventStore)
        
        // Set the title and notes
        reminder.title = title
        reminder.notes = notes
        
        // Set calendar (default reminders calendar)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        // Set due date
        let alarm = EKAlarm(absoluteDate: dueDate)
        reminder.addAlarm(alarm)
        
        // Set due date
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        
        do {
            try eventStore.save(reminder, commit: true)
            completion(.success(reminder.calendarItemIdentifier))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteReminder(with identifier: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let reminder = fetchReminder(with: identifier) else {
                continuation.resume(throwing: NSError(domain: "EventKitService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reminder not found"]))
                return
            }
            
            do {
                try eventStore.remove(reminder, commit: true)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func fetchReminder(with identifier: String) -> EKReminder? {
        guard let calendarItem = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            return nil
        }
        return calendarItem
    }
    
    func scheduleLocalNotification(title: String, body: String, date: Date) {
        let center = UNUserNotificationCenter.current()
        
        // Request permission
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            
            // Create the notification content
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            // Create trigger
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Create the request
            let identifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Add the notification request
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
}
