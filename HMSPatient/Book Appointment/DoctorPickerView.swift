import SwiftUI

struct DoctorPickerView: View {
    var doctors: [Doctor]
    @Binding var selectedDoctorIndex: Int?
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
            return doctors.filter { $0.name != "Select Doctor" }
        } else {
            return doctors.filter { removePrefix(from: $0.name).lowercased().contains(searchText.lowercased()) && $0.name != "Select Doctor" }
        }
    }

    var groupedDoctors: [String: [Doctor]] {
        Dictionary(grouping: filteredDoctors) { String(removePrefix(from: $0.name).prefix(1)).uppercased() }
    }

    var sortedKeys: [String] {
        groupedDoctors.keys.sorted()
    }

    var body: some View {
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
                                            .stroke(selectedDoctorIndex == doctors.firstIndex(where: { $0.id == doctor.id }) ? .customPrimary : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.customBackground)
        .navigationTitle("Select Doctor")
        .searchable(text: $searchText, prompt: "Search Doctor")
        .onAppear {
            print("DoctorPickerView appeared with \(doctors.count) doctors.")
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
                        .foregroundColor(.customPrimary)
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

    
}
