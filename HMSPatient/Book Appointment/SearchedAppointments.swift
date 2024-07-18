import SwiftUI
import FirebaseAuth

struct SearchedBookAppointment: View {
    var selectedDoctor: Doctor
    @State private var currentDate = Date()
    @Namespace private var calendarNamespace
    @State private var weeks: [[Date]] = []
    @State private var selectedTimeSlot: TimeSlot?
    @State private var isPremiumSlotsEnabled = false
    @State private var appointmentBooked = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                VStack {
                    DoctorCardView(doctor: selectedDoctor)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 20) {
                        ForEach(weeks.indices, id: \.self) { weekIndex in
                            WeekView(week: weeks[weekIndex], currentDate: $currentDate, calendarNamespace: calendarNamespace, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)
                                .frame(width: UIScreen.main.bounds.width - 40)
                        }
                    }
                }
                .padding(.vertical, 16)

                VStack {
                    TimeSlotView(selectedDoctor: selectedDoctor, timeSlots: selectedDoctor.generateTimeSlots(), selectedTimeSlot: $selectedTimeSlot, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)
                        .padding()
                        .cornerRadius(10)
                }

                HStack {
                    Toggle(isOn: $isPremiumSlotsEnabled) {
                        Text("Premium Slots")
                            .font(.headline)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#BC79B8")))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                NavigationLink(destination: AppointmentSummaryView(
                    selectedDoctor: selectedDoctor,
                    selectedTimeSlot: selectedTimeSlot,
                    appointmentDate: currentDate
                ), isActive: $appointmentBooked) {
                    Button(action: {
                        guard let selectedTimeSlot = selectedTimeSlot,
                              let currentUserId = Auth.auth().currentUser?.uid else {
                            print("Missing required information for booking appointment")
                            return
                        }
                        
                        let appointment = Appointment(
                            patientID: currentUserId,
                            doctorID: selectedDoctor.id,
                            date: currentDate,
                            timeSlotsID: selectedTimeSlot.id
                        )
                        
                        DataController.shared.saveAppointment(appointment: appointment) { success in
                            if success {
                                print("Appointment booked successfully")
                                self.appointmentBooked = true
                            } else {
                                print("Failed to book appointment")
                            }
                        }
                    }) {
                        Text("Book").fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(isPremiumSlotsEnabled ? Color(hex: "#AE75AC") : Color(hex: "0E6B60"))
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
            }
            .padding()
            .cornerRadius(10)
            .navigationTitle("Book Appointment")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                weeks = fetchWeeks(from: currentDate)
            }
        }
        .background(Color(hex: "ECEEEE"))
    }

    private func fetchWeeks(from baseDate: Date) -> [[Date]] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday as the first day of the week

        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: baseDate)) else {
            return []
        }

        return (0..<2).map { weekOffset in
            (0..<7).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: weekOffset * 7 + dayOffset, to: startOfWeek)
            }
        }
    }
}

struct SearchedTimeSlotView: View {
    let selectedDoctor: Doctor
    var timeSlots: [TimeSlot]

    @Binding var selectedTimeSlot: TimeSlot?
    @Binding var isPremiumSlotsEnabled: Bool

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        if timeSlots.isEmpty {
            Text("No time slots available")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(timeSlots.filter { timeSlot in
                    isPremiumSlotsEnabled ? timeSlot.isPremium : !timeSlot.isPremium
                }) { timeSlot in
                    Button(action: {
                        if timeSlot.isAvailable {
                            if selectedTimeSlot == timeSlot {
                                selectedTimeSlot = nil
                            } else {
                                selectedTimeSlot = timeSlot
                            }
                        }
                    }) {
                        Text(formatTimeSlot(timeSlot))
                            .font(.body)
                            .foregroundColor(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? .white : .black) : .gray)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? (timeSlot.isPremium ? Color(hex: "BC79B8") : Color(hex: "0E6B60")) : Color.white) : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .disabled(!timeSlot.isAvailable)
                }
            }
        }
    }

    private func formatTimeSlot(_ timeSlot: TimeSlot) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: timeSlot.startTime))   "
    }
}

//struct SearchedBookAppointment_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchedBookAppointment(selectedDoctor: )
//    }
//}
