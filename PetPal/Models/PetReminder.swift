import Foundation
import FirebaseFirestore

struct PetReminder: Identifiable, Codable {
    @DocumentID var id: String?
    var petName: String
    var message: String
    var date: Date
    var isCompleted: Bool = false
    
    // EventKit identifier to link with system reminders
    var eventIdentifier: String?
}

// For storing in Firestore
extension PetReminder {
    var dictionary: [String: Any] {
        return [
            "petName": petName,
            "message": message,
            "date": date,
            "isCompleted": isCompleted,
            "eventIdentifier": eventIdentifier ?? ""
        ]
    }
}
