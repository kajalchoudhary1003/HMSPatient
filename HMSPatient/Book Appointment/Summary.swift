import SwiftUI
import EventKit

struct AppointmentSummaryView: View {
    let selectedDoctor: Doctor?
    let selectedTimeSlot: TimeSlot?
    let appointmentDate: Date
    @StateObject private var eventKitManager = EventKitManager()
    @State private var showingEventAddedAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let doctor = selectedDoctor, let timeSlot = selectedTimeSlot {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Doctor:")
                        .font(.headline)
                    Text("\(doctor.firstName) \(doctor.lastName)")
                        .font(.body)
                    
                    Text("Age: \(calculateAge(from: doctor.dob))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Experience: \(doctor.experience) years")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text("Date:")
                        .font(.headline)
                    Text(formatDate(appointmentDate))
                        .font(.body)
                    
                    Text("Time Slot:")
                        .font(.headline)
                    Text(formatTimeSlot(timeSlot))
                        .font(.body)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                
                Spacer()
                Button(action: {
                    addEventToCalendar(doctor: doctor, timeSlot: timeSlot)
                }) {
                    HStack {
                        Text("Pay: ")
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                        
                        Text("\(doctor.fees)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "0E6B60"))
                    .cornerRadius(10)
                }
                .padding(.vertical)
                .alert(isPresented: $showingEventAddedAlert) {
                    Alert(title: Text("Event Added"), message: Text("The appointment has been added to your calendar."), dismissButton: .default(Text("OK")))
                }
            } else {
                Text("No appointment details available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
        .padding()
        .navigationBarTitle("Summary", displayMode: .large)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTimeSlot(_ timeSlot: TimeSlot) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
    }
    
    private func calculateAge(from birthDate: Date) -> Int {
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
    
    private func addEventToCalendar(doctor: Doctor, timeSlot: TimeSlot) {
        let notesFormatter = DateFormatter()
        notesFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let formattedDate = notesFormatter.string(from: appointmentDate)

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let formattedStartTime = timeFormatter.string(from: timeSlot.startTime)
        let formattedEndTime = timeFormatter.string(from: timeSlot.endTime)

        let notes = """
        Doctor: Dr. \(doctor.firstName) \(doctor.lastName)
        Designation: \(doctor.designation)
        Date: \(formattedDate)
        Time: \(formattedStartTime) - \(formattedEndTime)

        Location: [Insert clinic/hospital name]
        Address: [Insert address]

        Please arrive 15 minutes early.
        Bring your insurance card and ID.
        """

        eventKitManager.requestCalendarAccessAndAddEvent(
            title: "Doctor Appointment - Dr. \(doctor.lastName)",
            startDate: timeSlot.startTime,
            endDate: timeSlot.endTime,
            notes: notes
        ) { success in
            if success {
                print("Event added to calendar successfully")
                showingEventAddedAlert = true
            } else {
                print("Failed to add event to calendar")
                // You might want to show an error alert here
            }
        }
    }
}

extension Int {
    func currencyFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

struct AppointmentSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentSummaryView(selectedDoctor: nil, selectedTimeSlot: nil, appointmentDate: Date())
    }
}
