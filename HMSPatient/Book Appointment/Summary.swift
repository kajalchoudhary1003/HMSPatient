import SwiftUI
import EventKit
import FirebaseAuth

struct AppointmentSummaryView: View {
    let selectedDoctor: Doctor?
    let selectedTimeSlot: TimeSlot?
    let appointmentDate: Date
    @StateObject private var eventKitManager = EventKitManager()
    @State private var showingEventAddedAlert = false
    @State private var bookingErrorMessage: IdentifiableError?
    @State private var showSuccessAnimation = false
    @State private var animationFinished = false

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
                    guard let currentUserId = Auth.auth().currentUser?.uid else {
                        bookingErrorMessage = IdentifiableError(message: "User not authenticated")
                        return
                    }
                    
                    let appointment = Appointment(
                        patientID: currentUserId,
                        doctorID: doctor.id,
                        date: appointmentDate,
                        timeSlotID: timeSlot.id
                    )
                    
                    DataController.shared.saveAppointment(appointment: appointment) { success in
                        if success {
                            print("Appointment booked successfully")
                            addEventToCalendar(doctor: doctor, timeSlot: timeSlot)
                            showSuccessAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                animationFinished = true
                            }
                        } else {
                            bookingErrorMessage = IdentifiableError(message: "Failed to book appointment")
                            print("Failed to book appointment")
                        }
                    }
                }) {
                    Text("Book & Pay: \(doctor.fees)")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "0E6B60"))
                        .cornerRadius(10)
                }
                .padding(.vertical)
                .alert(isPresented: $showingEventAddedAlert) {
                    Alert(title: Text("Event Added"), message: Text("The appointment has been added to your calendar."), dismissButton: .default(Text("OK")))
                }
                .alert(item: $bookingErrorMessage) { error in
                    Alert(title: Text("Booking Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
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
            
            if showSuccessAnimation {
                SuccessAnimationView()
                    .onAppear {
                        // Perform any cleanup after animation finishes if needed
                    }
            }
        }
        .padding()
        .navigationBarTitle("Summary", displayMode: .large)
        .background(
            NavigationLink(destination: HomeView(), isActive: $animationFinished) {
                EmptyView()
            }
            .navigationBarHidden(true)
        )
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
                bookingErrorMessage = IdentifiableError(message: "Failed to add event to calendar")
            }
        }
    }
}

struct SuccessAnimationView: View {
    @State private var showTick = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            if showTick {
                Image("tickMark") // Use the name of your tick mark image asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .transition(.scale)
            }
            
            if showConfetti {
                ForEach(0..<20) { index in
                    ConfettiView()
                        .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -300...300))
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1)) {
                showTick = true
            }
            withAnimation(.easeInOut(duration: 1).delay(1)) {
                showConfetti = true
            }
        }
    }
}

struct ConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle() // You can use other shapes or images for confetti
            .fill(Color.random)
            .frame(width: 10, height: 10)
            .offset(y: isAnimating ? 500 : -500)
            .onAppear {
                withAnimation(.linear(duration: 2)) {
                    isAnimating = true
                }
            }
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}
