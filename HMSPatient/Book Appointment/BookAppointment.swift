import SwiftUI
import FirebaseAuth

struct BookAppointment: View {
    @State private var selectedDoctor: Doctor?
    @State private var selectedCategoryIndex = 0
    @State private var selectedDoctorIndex: Int? = nil
    @State private var currentDate = Date()
    @Namespace private var calendarNamespace
    @State private var doctorSelected = false
    @State private var weeks: [[Date]] = []
    @State private var selectedTimeSlot: TimeSlot?
    @State private var isPremiumSlotsEnabled = false
    @State private var filteredDoctors: [Doctor] = []
    @State private var isLoadingDoctors = false
    @State private var generatedTimeSlots: [TimeSlot] = []
    @StateObject private var eventKitManager = EventKitManager()
    @State private var appointmentBooked = false
    var categories: [DoctorDesignation?] = DoctorDesignation.withSelectOption

    init(selectedDoctor: Doctor? = nil) {
        _selectedDoctor = State(initialValue: selectedDoctor)
        _doctorSelected = State(initialValue: selectedDoctor != nil)
        setupInitialState()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Speciality")
                        Spacer()
                        Picker("Speciality", selection: $selectedCategoryIndex.onChange(categoryChanged)) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                Text(categories[index]?.title ?? "Select").tag(index as Int?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding()
                    .background(Color("SecondaryColor"))
                    .cornerRadius(10)

                    if selectedCategoryIndex != 0 {
                        NavigationLink(destination: DoctorPickerView(doctors: filteredDoctors, selectedDoctorIndex: $selectedDoctorIndex)) {
                            HStack {
                                Text(selectedDoctorLabel)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(selectedDoctorIndex != nil ? .gray :
                                    Color("TextColor"))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onChange(of: selectedDoctorIndex) { newValue in
                                if let index = newValue, let doctor = filteredDoctors[safe: index] {
                                    generatedTimeSlots = doctor.generateTimeSlots()
                                    doctorSelected = true
                                    print("Generated \(generatedTimeSlots.count) time slots for \(doctor.name)")
                                } else {
                                    generatedTimeSlots = []
                                    doctorSelected = false
                                }
                            }
                        }
                        .background(Color("SecondaryColor"))
                        .cornerRadius(10)
                        .disabled(selectedCategoryIndex == 0)
                    }
                }

                if doctorSelected,
                   let selectedDoctor = filteredDoctors[safe: selectedDoctorIndex ?? -1] {
                    VStack {
                        DoctorCardView(doctor: selectedDoctor)
                            .padding()
                            .background(Color("SecondaryColor"))
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

                    if let selectedDoctor = filteredDoctors[safe: selectedDoctorIndex ?? -1] {
                        VStack {
                            TimeSlotView(selectedDoctor: selectedDoctor, timeSlots: generatedTimeSlots, selectedTimeSlot: $selectedTimeSlot, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)
                                .padding()
                                .cornerRadius(10)
                        }
                    }

                    HStack {
                        Toggle(isOn: $isPremiumSlotsEnabled) {
                            Text("Premium Slots")
                                .font(.headline)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color("PremiumColor")))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color("SecondaryColor"))
                    .cornerRadius(10)

                    NavigationLink(destination:
                        AppointmentSummaryView(
                            selectedDoctor: filteredDoctors[safe: selectedDoctorIndex ?? -1],
                            selectedTimeSlot: selectedTimeSlot,
                            appointmentDate: currentDate
                        )
                    ) {
                        Text("Proceed")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Group {
                                if selectedTimeSlot == nil {
                                    Color(UIColor.systemGray)
                                } else if isPremiumSlotsEnabled {
                                    Color.customPremium
                                } else {
                                    Color.customPrimary
                                }
                            })
                            .cornerRadius(10)
                            .padding(.vertical)
                    }
                    .disabled(selectedTimeSlot == nil)// Disable the button if no time slot is selected
                }
            }
            .padding()
            .cornerRadius(10)
            .navigationTitle("Book Appointment")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupInitialState()
            }
            .onChange(of: selectedDoctor) { newDoctor in
                if let doctor = newDoctor {
                    selectedCategoryIndex = categories.firstIndex(where: { $0 == doctor.designation }) ?? 0
                    fetchDoctors()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selectedDoctorIndex = filteredDoctors.firstIndex(where: { $0.id == doctor.id })
                        doctorSelected = true
                        generatedTimeSlots = doctor.generateTimeSlots()
                    }
                }
            }
        }
        .background(Color.customBackground)
    }
    
    private func setupInitialState() {
        weeks = fetchWeeks(from: currentDate)
        if let doctor = selectedDoctor {
            selectedCategoryIndex = categories.firstIndex(where: { $0 == doctor.designation }) ?? 0
            fetchDoctors() // This will populate filteredDoctors
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Small delay to ensure filteredDoctors is populated
                selectedDoctorIndex = filteredDoctors.firstIndex(where: { $0.id == doctor.id })
                doctorSelected = true
                generatedTimeSlots = doctor.generateTimeSlots()
            }
        }
    }
    
    private func categoryChanged(_ index: Int) {
        selectedDoctorIndex = nil
        doctorSelected = false
        fetchDoctors()
    }
    
    private func fetchDoctors() {
        guard let selectedCategory = categories[safe: selectedCategoryIndex] else { return }
        isLoadingDoctors = true
        DataController.shared.fetchDoctors(byCategory: selectedCategory) { doctors in
            DispatchQueue.main.async {
                filteredDoctors = doctors
                isLoadingDoctors = false
                print("Filtered doctors count: \(filteredDoctors.count)")
                
                // Update selectedDoctorIndex if a doctor was pre-selected
                if let selectedDoctor = selectedDoctor {
                    selectedDoctorIndex = filteredDoctors.firstIndex(where: { $0.id == selectedDoctor.id })
                }
            }
        }
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
                            .foregroundColor(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? .white :  Color("TextColor")) : .gray)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? (timeSlot.isPremium ? Color("PremiumColor") : .customPrimary) : Color("SecondaryColor")) : Color.gray.opacity(0.3))
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
