import SwiftUI

struct BookAppointment: View {
    @State private var selectedCategoryIndex = 0
    @State private var selectedDoctorIndex: Int? = nil
    @State private var currentDate = Date()
    @Namespace private var calendarNamespace
    @State private var doctorSelected = false
    @State private var weeks: [[Date]] = []
    @State private var selectedTimeSlot: TimeSlot?
    @State private var isPremiumSlotsEnabled = false

    var doctors: [Doctor]
    var categories: [DoctorDesignation?] = DoctorDesignation.withSelectOption

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Speciality")
                            .font(.headline)

                        Spacer()

                        Picker("Speciality", selection: $selectedCategoryIndex.onChange(resetSelections)) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                Text(categories[index]?.title ?? "Select").tag(index as Int?)
                            }
                        }
                        .pickerStyle(.menu)

                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                    if selectedCategoryIndex != 0 {
                        NavigationLink(destination:
                            DoctorPickerView(doctors: doctors, selectedDoctorIndex: Binding(
                                get: {
                                    selectedDoctorIndex
                                },
                                set: { newValue in
                                    selectedDoctorIndex = newValue
                                    doctorSelected = newValue != nil
                                }
                            ))
                        ){
                            HStack {
                                Text(selectedDoctorLabel)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(selectedDoctorIndex != nil ? .gray : .black) // Adjusted color based on selection
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .disabled(selectedCategoryIndex == 0)
                    }
                }

                if doctorSelected,
                   let selectedDoctor = doctors[safe: selectedDoctorIndex ?? -1] {
                    VStack {
                        DoctorCardView(doctor: selectedDoctor)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }

                if doctorSelected {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 20) {
                            ForEach(weeks.indices, id: \.self) { weekIndex in
                                WeekView(week: weeks[weekIndex], currentDate: $currentDate, calendarNamespace: calendarNamespace, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)
                                    .frame(width: UIScreen.main.bounds.width - 40)
                            }
                        }
                    }
                    .padding(.vertical, 16)

                    if let selectedDoctor = doctors[safe: selectedDoctorIndex ?? -1] {
                        VStack {
                            TimeSlotView(selectedDoctor: selectedDoctor, timeSlots: selectedDoctor.timeSlots, selectedTimeSlot: $selectedTimeSlot, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)
                                .padding()
                                .cornerRadius(10)
                        }
                    }

                    HStack {
                        Toggle(isOn: $isPremiumSlotsEnabled) {
                            Text("Premium Slots")
                                .font(.headline)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#AE75AC")))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                    Button(action: {
                        // Implement booking action here
                    }) {
                        Text("Book").fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding().padding(.vertical, 4)
                            .background(isPremiumSlotsEnabled ? Color(hex: "#AE75AC") : Color(hex: "006666"))
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

    private func resetSelections(_ index: Int) {
        selectedDoctorIndex = nil
        doctorSelected = false
    }

    private var selectedDoctorLabel: String {
        if let _ = selectedDoctorIndex {
            return "Change Doctor"
        } else {
            return "Select Doctor"
        }
    }
}

struct TimeSlotView: View {
    let selectedDoctor: Doctor
    var timeSlots: [TimeSlot]

    @Binding var selectedTimeSlot: TimeSlot?
    @Binding var isPremiumSlotsEnabled: Bool

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(timeSlots.filter { timeSlot in
                if isPremiumSlotsEnabled {
                    return timeSlot.isPremium
                } else {
                    return !timeSlot.isPremium
                }
            }) { timeSlot in
                Button(action: {
                    if timeSlot.isAvailable {
                        selectedTimeSlot = timeSlot
                    }
                }) {
                    Text("\(timeSlot.startTime)") // Adjust as per your TimeSlot structure
                        .font(.body)
                        .foregroundColor(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? .white : .black) : .gray)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? (timeSlot.isPremium ? Color(hex:"8C309D") : Color(hex: "006666")) : Color.white) : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .disabled(!timeSlot.isAvailable)
            }
        }
    }
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

struct BookAppointment_Previews: PreviewProvider {
    static var previews: some View {
        BookAppointment(doctors: [
            Doctor(
                id: "1",
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com",
                phone: "123-456-7890",
                dob: Date(),
                designation: .generalPractitioner,
                titles: "MD",
                timeSlots: [],
                experience: 10
            ),
            Doctor(
                id: "2",
                firstName: "Jane",
                lastName: "Smith",
                email: "jane.smith@example.com",
                phone: "987-654-3210",
                dob: Date(),
                designation: .cardiologist,
                titles: "MD",
                timeSlots: [],
                experience: 8
            )
        ])
    }
}
