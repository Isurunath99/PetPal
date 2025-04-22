import SwiftUI

struct PetReminderCardView: View {
    let reminder: PetReminder
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                Text(dateFormatter.string(from: reminder.date))
                Image(systemName: "clock")
                Text(timeFormatter.string(from: reminder.date))
                Image(systemName: "dog")
                Text(reminder.petName)
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            Text(reminder.message)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .fixedSize(horizontal: true, vertical: false)
    }
}
