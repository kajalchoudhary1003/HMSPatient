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
    @State private var descriptionText = ""

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                if let doctor = selectedDoctor, let timeSlot = selectedTimeSlot {
                    VStack(alignment: .leading, spacing: 8) {
                        Section(header: Text("Appointment Details").font(.headline)) {
                            HStack {
                                
                                    VStack(alignment: .leading) {
                                        Text("Dr. \(doctor.firstName) \(doctor.lastName)")
                                            .font(.title)
                                        Text(doctor.designation.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 5)
                                        Text("\(formatTimeSlot(timeSlot))")
                                            .font(.subheadline)
                                            .foregroundColor(.customPrimary)
                                    }
                                    Spacer()
                                    VStack(alignment: .center) {
                                        Text(formatDayOfWeek(appointmentDate))
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.customPrimary)
                                        Text(formatDayOfMonth(appointmentDate))
                                            .font(.largeTitle)
                                            .fontWeight(.regular)
                                    }
                            }
                            .padding()
                            .padding(.horizontal,10)
                            .background(Color("SecondaryColor"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Section(header: Text("Write Description").font(.headline)) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $descriptionText)
                                    .frame(height: 150)
                                    .padding(6)
                                    .background(Color("SecondaryColor"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(UIColor.systemGray), lineWidth: 1)
                                    )
                                
                                if descriptionText.isEmpty {
                                    Text("Describe your problem...")
                                        .foregroundColor(Color(UIColor.placeholderText))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 14)
                                        .allowsHitTesting(false)
                                }
                            }
                        }

                    }
                    
                    Spacer()
                    
                    Button(action: {
                        guard let currentUserId = Auth.auth().currentUser?.uid else {
                            bookingErrorMessage = IdentifiableError(message: "User not authenticated")
                            return
                        }
                            
                            var timeSlot = selectedTimeSlot
                            timeSlot?.isAvailable = false

                            guard let timeSlot = timeSlot else {
                                bookingErrorMessage = IdentifiableError(message: "Invalid time slot")
                                return
                            }
                        
                        let appointment = Appointment(
                            id: UUID().uuidString,
                            patientID: currentUserId,
                            doctorID: doctor.id,
                            date: appointmentDate,
                            shortDescription: descriptionText,
                            timeSlot: timeSlot,isCompleted: false
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
                        Text("Pay: \(doctor.fees)")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.customPrimary)
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
                        .background(Color("SecondaryColor"))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
            }
            .padding()
            .navigationBarTitle("Summary", displayMode: .large)
            .background(
                EmptyView()
                    .onChange(of: animationFinished) { finished in
                        if finished {
                            DispatchQueue.main.async {
                                if let window = UIApplication.shared.windows.first {
                                    window.rootViewController = UIHostingController(rootView: HomeView())
                                    window.makeKeyAndVisible()
                                }
                            }
                        }
                    }
            )
            
            if showSuccessAnimation {
                SuccessAnimationView()
                    .edgesIgnoringSafeArea(.all)
            }
        }.background(Color.customBackground)
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

    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func formatDayOfMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
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
            Blur()
            
            if showConfetti {
                            ConfettiContainer()
                        }
            
            VStack {
                if showTick {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(UIColor.systemGreen))
                        .transition(.scale)
                }
                
                Text("Appointment Booked!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.customPrimary)
                    .padding(.top)
                    .opacity(showTick ? 1 : 0)
            }
            
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                showTick = true
            }
            withAnimation(.easeOut(duration: 1).delay(0.5)) {
                showConfetti = true
            }
        }
    }
}

struct ConfettiContainer: View {
    let confettiCount = 50
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<confettiCount, id: \.self) { _ in
                ConfettiView(size: geometry.size)
            }
        }
    }
}

struct ConfettiView: View {
    @State private var isAnimating = false
    let size: CGSize
    
    private let randomX: CGFloat
    private let randomY: CGFloat
    private let randomScale: CGFloat
    private let randomRotation: Double
    private let randomDuration: Double
    private let randomDelay: Double
    
    init(size: CGSize) {
        self.size = size
        randomX = CGFloat.random(in: -size.width...size.width)
        randomY = CGFloat.random(in: -size.height...size.height)
        randomScale = CGFloat.random(in: 0.5...1.5)
        randomRotation = Double.random(in: 0...360)
        randomDuration = Double.random(in: 1.5...3)
        randomDelay = Double.random(in: 0...0.5)
    }
    
    var body: some View {
        Circle()
            .fill(Color.random)
            .frame(width: 10, height: 10)
            .scaleEffect(isAnimating ? randomScale : 0.01)
            .offset(x: isAnimating ? randomX : 0, y: isAnimating ? randomY : 0)
            .rotationEffect(.degrees(isAnimating ? randomRotation : 0))
            .opacity(isAnimating ? 0 : 1)
            .animation(
                Animation.easeOut(duration: randomDuration)
                    .delay(randomDelay)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
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
