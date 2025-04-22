import SwiftUI

struct AddReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var authManager: AuthManager
//    @Binding var navPath: NavigationPath
    
    @State private var petName: String = ""
    @State private var reminderMessage: String = ""
    @State private var reminderDate: Date = Date()
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Callback to save the reminder
    var onSave: (String, String, Date) -> Void
    
    // Time selection helpers
    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date())
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var isAM: Bool = Calendar.current.component(.hour, from: Date()) < 12
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet Information")) {
                    TextField("Pet Name", text: $petName)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("Date & Time", selection: $reminderDate)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .frame(maxHeight: 400)
                    
                    // Custom time picker
                    HStack {
                        Spacer()
                        
                        // Hours picker
                        Picker("", selection: $selectedHour) {
                            ForEach(1...12, id: \.self) { hour in
                                Text("\(hour)")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 50)
                        .clipped()
                        
                        Text(":")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Minutes picker
                        Picker("", selection: $selectedMinute) {
                            ForEach(0..<60) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 50)
                        .clipped()
                        
                        // AM/PM picker
                        Picker("", selection: $isAM) {
                            Text("AM").tag(true)
                            Text("PM").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 100)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Reminder")) {
                    ZStack(alignment: .topLeading) {
                        if reminderMessage.isEmpty {
                            Text("Enter reminder details here...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $reminderMessage)
                            .frame(minHeight: 100)
                            .padding(.horizontal, -5)
                    }
                }
                
                Button(action: saveReminder) {
                    Text("Add reminder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
            }
            .navigationTitle("Add Reminder")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: selectedHour) { _ in updateTime() }
            .onChange(of: selectedMinute) { _ in updateTime() }
            .onChange(of: isAM) { _ in updateTime() }
            .onAppear {
                // Initialize time pickers with current time
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                if let hour = components.hour, let minute = components.minute {
                    selectedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
                    selectedMinute = minute
                    isAM = hour < 12
                }
            }
        }
    }
    
    // Update the reminderDate based on time picker values
    private func updateTime() {
        var calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        
        // Convert hour to 24-hour format
        var hour = selectedHour
        if (!isAM && hour < 12) {
            hour += 12
        } else if (isAM && hour == 12) {
            hour = 0
        }
        
        components.hour = hour
        components.minute = selectedMinute
        
        if let newDate = calendar.date(from: components) {
            reminderDate = newDate
        }
    }
    
    // Save the reminder
    private func saveReminder() {
        // Validate inputs
        guard !petName.isEmpty else {
            errorMessage = "Please enter a pet name"
            showingError = true
            return
        }
        
        guard !reminderMessage.isEmpty else {
            errorMessage = "Please enter a reminder message"
            showingError = true
            return
        }
        
        // Ensure date is in the future
        guard reminderDate > Date() else {
            errorMessage = "Please select a future date/time"
            showingError = true
            return
        }
        
        // Save the reminder
        onSave(petName, reminderMessage, reminderDate)
    }
}
