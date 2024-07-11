import SwiftUI

// Sample data for pickers
let categories = ["Select", "General Checkup", "Dental", "Orthopedic", "Pediatric"]
let doctors = [
    [],
    [
        Doctor(name: "Select Doctor", experience: 0, age: 0, fees: 0, availableTimeSlots: [
            TimeSlot(time: "00:00 AM", isAvailable: true, isPremium: false),
        ]),
        Doctor(name: "Dr. Smith", experience: 10, age: 45, fees: 100, availableTimeSlots: [
            TimeSlot(time: "09:00 - 09:15 AM", isAvailable: true, isPremium: false),
            TimeSlot(time: "09:20 - 09:35 AM", isAvailable: false, isPremium: true),
            TimeSlot(time: "09:40 - 09:55 AM", isAvailable: true, isPremium: false),
            TimeSlot(time: "10:00 - 10:15 AM", isAvailable: false, isPremium: true),
            TimeSlot(time: "10:20 - 10:35 AM", isAvailable: true, isPremium: true)
        ]),
        Doctor(name: "Dr. Matt", experience: 9, age: 45, fees: 100, availableTimeSlots: [
            TimeSlot(time: "09:00 AM", isAvailable: false, isPremium: false),
            TimeSlot(time: "09:20 AM", isAvailable: false, isPremium: true),
            TimeSlot(time: "09:40 AM", isAvailable: true, isPremium: true),
            TimeSlot(time: "10:00 AM", isAvailable: false, isPremium: false),
            TimeSlot(time: "10:20 AM", isAvailable: true, isPremium: false)
        ])
    ],
    [
        Doctor(name: "Select Doctor", experience: 0, age: 0, fees: 0, availableTimeSlots: [
            TimeSlot(time: "00:00 AM", isAvailable: true, isPremium: false),
        ]),
        Doctor(name: "Dr. Lee", experience: 12, age: 50, fees: 110, availableTimeSlots: [
            TimeSlot(time: "09:00 AM", isAvailable: true, isPremium: true),
            TimeSlot(time: "10:00 AM", isAvailable: true, isPremium: false),
            TimeSlot(time: "11:00 AM", isAvailable: false, isPremium: false)
        ]),
        Doctor(name: "Dr. Smith", experience: 10, age: 45, fees: 100, availableTimeSlots: [
            TimeSlot(time: "09:00 AM", isAvailable: true, isPremium: false),
            TimeSlot(time: "10:00 AM", isAvailable: false, isPremium: true),
            TimeSlot(time: "11:00 AM", isAvailable: true, isPremium: true)
        ])
    ],
    [
        Doctor(name: "Select Doctor", experience: 0, age: 0, fees: 0, availableTimeSlots: [
            TimeSlot(time: "00:00 AM", isAvailable: true, isPremium: false),
        ]),
        Doctor(name: "Dr. White", experience: 15, age: 55, fees: 130, availableTimeSlots: [
            TimeSlot(time: "09:00 AM", isAvailable: false, isPremium: true),
            TimeSlot(time: "10:00 AM", isAvailable: true, isPremium: false),
            TimeSlot(time: "11:00 AM", isAvailable: true, isPremium: true)
        ]),
        Doctor(name: "Dr. Matt", experience: 9, age: 45, fees: 100, availableTimeSlots: [
            TimeSlot(time: "09:00 AM", isAvailable: false, isPremium: false),
            TimeSlot(time: "10:00 AM", isAvailable: false, isPremium: true),
            TimeSlot(time: "11:00 AM", isAvailable: true, isPremium: true)
        ])
    ],
    [
        Doctor(name: "Select Doctor", experience: 0, age: 0, fees: 0, availableTimeSlots: [
            TimeSlot(time: "00:00 AM", isAvailable: true, isPremium: false),
        ]),
        Doctor(name: "Dr. Hall", experience: 11, age: 48, fees: 120, availableTimeSlots: [
            TimeSlot(time: "09:00 AM", isAvailable: true, isPremium: true),
            TimeSlot(time: "10:00 AM", isAvailable: true, isPremium: false),
            TimeSlot(time: "11:00 AM", isAvailable: false, isPremium: false)
        ])
    ]
]

struct BookAppointment: View {
    @State private var selectedCategoryIndex = 0
    @State private var selectedDoctorIndex: Int? = nil
    @State private var currentDate = Date()
    @Namespace private var calendarNamespace
    @State private var doctorSelected = false
    @State private var weeks: [[Date]] = []
    @State private var selectedTimeSlot: TimeSlot?
    @State private var isPremiumSlotsEnabled = false  // Ensure this state is declared here

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Speciality")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Speciality", selection: $selectedCategoryIndex.onChange(resetSelections)) {
                            ForEach(0..<categories.count) { index in
                                Text(categories[index]).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    NavigationLink(destination: DoctorPickerView(doctors: doctors[selectedCategoryIndex], selectedDoctorIndex: Binding(
                        get: {
                            selectedDoctorIndex ?? 0
                        },
                        set: { newValue in
                            selectedDoctorIndex = newValue == 0 ? nil : newValue
                        }
                    ))) {
                        HStack {
                            Text("Select Doctor")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(selectedDoctorIndex != nil ? .black : .gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .disabled(selectedCategoryIndex == 0)
                    .onChange(of: selectedDoctorIndex) { _ in
                        doctorSelected = selectedDoctorIndex != nil
                    }
                }

                if doctorSelected,
                   let selectedDoctor = doctors[safe: selectedCategoryIndex]?[safe: selectedDoctorIndex ?? -1] {
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
                    .padding(.vertical,16)

                    if let selectedDoctor = doctors[safe: selectedCategoryIndex]?[safe: selectedDoctorIndex ?? -1] {
                        VStack {
                            TimeSlotView(selectedDoctor: selectedDoctor, timeSlots: selectedDoctor.availableTimeSlots, selectedTimeSlot: $selectedTimeSlot, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)  // Pass isPremiumSlotsEnabled here
                                .padding()
                                .cornerRadius(10)
                        }
                    }
                    HStack {
                        Toggle(isOn: $isPremiumSlotsEnabled) {
                            Text("Premium Slots")
                                .font(.headline)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.systemOrange)))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                    Button(action: {
                        // Action when the button is tapped
                    }) {
                        Text("Book").fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white) // Text color
                            .padding().padding(.vertical,4)
                            .background(isPremiumSlotsEnabled ? Color(UIColor.systemOrange) : Color(hex: "006666")) // Background color
                            .cornerRadius(10) // Rounded corners if needed
                    }.padding(.vertical)

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
}

struct TimeSlotView: View {
    let selectedDoctor: Doctor
    var timeSlots: [TimeSlot]

    @Binding var selectedTimeSlot: TimeSlot?
    @Binding var isPremiumSlotsEnabled: Bool  // Add binding for isPremiumSlotsEnabled

    // Adjust columns from three to two
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
                    Text(timeSlot.time)
                        .font(.body)
                        .foregroundColor(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? .white : .black) : .gray)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 50) // Adjust frame properties
                        .background(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? (timeSlot.isPremium ? Color.orange : Color(hex: "006666")) : Color.white) : Color.gray.opacity(0.3))
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
        BookAppointment()
    }
}
