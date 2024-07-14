import SwiftUI
import FirebaseAuth

struct BookAppointment: View {
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
    var categories: [DoctorDesignation?] = DoctorDesignation.withSelectOption
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Speciality")
                            .font(.headline)

                        Spacer()

                        Picker("Speciality", selection: $selectedCategoryIndex.onChange(categoryChanged)) {
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
                        NavigationLink(destination: DoctorPickerView(doctors: $filteredDoctors, selectedDoctorIndex: $selectedDoctorIndex, isLoading: $isLoadingDoctors)) {
                            HStack {
                                Text(selectedDoctorLabel)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(selectedDoctorIndex != nil ? .gray : .black)
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
                        .background(Color.white)
                        .cornerRadius(10)
                        .disabled(selectedCategoryIndex == 0)
                    }
                }

                if doctorSelected,
                   let selectedDoctor = filteredDoctors[safe: selectedDoctorIndex ?? -1] {
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
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#AE75AC")))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

Button(action: {
    guard let selectedDoctor = filteredDoctors[safe: selectedDoctorIndex ?? -1],
          let selectedTimeSlot = selectedTimeSlot,
          let currentUserId = Auth.auth().currentUser?.uid else {
        print("Missing required information for booking appointment")
        return
    }
    
    let appointment = Appointment(
        patientID: currentUserId,
        doctorID: selectedDoctor.id,
        date: currentDate,
        timeSlotID: selectedTimeSlot.id
    )
    
    DataController.shared.saveAppointment(appointment: appointment) { success in
        if success {
            // Handle successful appointment booking
            print("Appointment booked successfully")
            // You might want to show an alert or navigate to a confirmation screen here
        } else {
            // Handle error in booking appointment
            print("Failed to book appointment")
            // You might want to show an error alert here
        }
    }
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
                            .background(timeSlot.isAvailable ? (timeSlot == selectedTimeSlot ? (timeSlot.isPremium ? Color(hex:"8C309D") : Color(hex: "006666")) : Color.white) : Color.gray.opacity(0.3))
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

struct DoctorPickerView: View {
    @Binding var doctors: [Doctor]
    @Binding var selectedDoctorIndex: Int?
    @Binding var isLoading: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""

    func removePrefix(from name: String) -> String {
        if name.hasPrefix("Dr. ") {
            return String(name.dropFirst(4))
        }
        return name
    }

    var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return doctors
        } else {
            return doctors.filter { removePrefix(from: $0.name).lowercased().contains(searchText.lowercased()) }
        }
    }

    var groupedDoctors: [String: [Doctor]] {
        Dictionary(grouping: filteredDoctors) { String(removePrefix(from: $0.name).prefix(1)).uppercased() }
    }

    var sortedKeys: [String] {
        groupedDoctors.keys.sorted()
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.0)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(sortedKeys, id: \.self) { key in
                            Section(header: Text(key)) {
                                ForEach(groupedDoctors[key]!, id: \.id) { doctor in
                                    Button(action: {
                                        if let index = doctors.firstIndex(where: { $0.id == doctor.id }) {
                                            print("Selected doctor: \(doctor.name), Index: \(index)")
                                            selectedDoctorIndex = index
                                            presentationMode.wrappedValue.dismiss()
                                        } else {
                                            print("Doctor not found in doctors array.")
                                        }
                                    }) {
                                        DoctorCardView(doctor: doctor)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedDoctorIndex == doctors.firstIndex(where: { $0.id == doctor.id }) ? Color(hex: "006666") : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(hex: "ECEEEE"))
                .navigationTitle("Select Doctor")
                .searchable(text: $searchText, prompt: "Search Doctor")
                .onAppear {
                    print("DoctorPickerView appeared with \(doctors.count) doctors.")
                }
            }
        }
    }
}

struct DoctorCardView: View {
    var doctor: Doctor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(doctor.name)
                .font(.title2)
                .foregroundColor(.black)

            if doctor.name != "Select Doctor" {
                Text("Age: \(calculateAge(from: doctor.dob))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Text("Experience: \(doctor.experience) years")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Spacer()

                    Text(String(format: "Fees: %@", doctor.fees))
                        .font(.footnote)
                        .foregroundColor(Color(hex: "006666"))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .onAppear {
            print("DoctorCardView appeared for \(doctor.name)")
        }
    }

    private func calculateAge(from dateOfBirth: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
}
