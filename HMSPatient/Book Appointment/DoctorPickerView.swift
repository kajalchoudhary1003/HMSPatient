import SwiftUI

struct DoctorPickerView: View {
    var doctors: [Doctor]
    @Binding var selectedDoctorIndex: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""

    // Helper function to remove "Dr. " prefix
    func removePrefix(from name: String) -> String {
        if name.hasPrefix("Dr. ") {
            return String(name.dropFirst(4))
        }
        return name
    }

    // Computed property to filter doctors based on search text
    var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return doctors
        } else {
            return doctors.filter { removePrefix(from: $0.name).lowercased().contains(searchText.lowercased()) }
        }
    }

    // Computed property to group doctors by the first letter of their name
    var groupedDoctors: [String: [Doctor]] {
        Dictionary(grouping: filteredDoctors) { String(removePrefix(from: $0.name).prefix(1)).uppercased() }
    }

    // Computed property to get sorted keys for sections
    var sortedKeys: [String] {
        groupedDoctors.keys.sorted()
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(sortedKeys, id: \.self) { key in
                    Section(header: Text(key)) {
                        // Filter out "Select Doctor" option from the list
                        ForEach(groupedDoctors[key]!.filter { $0.name != "Select Doctor" }, id: \.id) { doctor in
                            Button(action: {
                                if let index = doctors.firstIndex(where: { $0.id == doctor.id }) {
                                    selectedDoctorIndex = index
                                    presentationMode.wrappedValue.dismiss() // Dismiss the view after selection
                                }
                            }) {
                                DoctorCardView(doctor: doctor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedDoctorIndex == doctors.firstIndex(where: { $0.id == doctor.id }) ? Color(hex:"006666") : Color.clear, lineWidth: 2)
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
    }
}

struct DoctorCardView: View {
    var doctor: Doctor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(doctor.name)
                .font(.title2)
                .foregroundColor(.black)

            Text("Age: \(doctor.age)")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Text("Experience: \(doctor.experience) years")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()

                Text(String(format: "Fees: Rs.%.2f", doctor.fees))
                    .font(.footnote)
                    .foregroundColor(Color(hex: "006666"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

