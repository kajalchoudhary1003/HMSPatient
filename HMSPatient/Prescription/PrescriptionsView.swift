import SwiftUI

struct PrescriptionListView: View {
    @State private var searchText = ""
    
    // Sample prescription data
    let prescriptions = [
        Prescription(doctorName: "Dr. Seema Gupta", date: "4 July, 2024", details: ["Amoxicillin (500mg) - 2 capsules"]),
        Prescription(doctorName: "Dr. Seema Gupta", date: "24 June, 2024", details: ["Sertraline (500mg) - 2 capsules"]),
        Prescription(doctorName: "Dr. Rajesh Waghle", date: "10 June, 2024", details: ["Ibuprofen (150mg) - 1 tablet"]),
        Prescription(doctorName: "Dr. Anmol Kriti", date: "6 May, 2024", details: ["Paracetamol (500mg) - 3 tablets"])
    ]
    
    var body: some View {
        VStack {
            List(filteredPrescriptions, id: \.id) { prescription in
                NavigationLink(destination: PrescriptionDetailView(date: prescription.date, details: prescription.details)) {
                    PrescriptionRow(doctorName: prescription.doctorName, date: prescription.date, details: prescription.details.first ?? "")
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("My Prescriptions")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
        .background(Color.customBackground)
        .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size to the main view
    }
    
    // Computed property for filtered prescriptions
    var filteredPrescriptions: [Prescription] {
        if searchText.isEmpty {
            return prescriptions
        } else {
            return prescriptions.filter { prescription in
                prescription.doctorName.lowercased().contains(searchText.lowercased()) ||
                prescription.date.lowercased().contains(searchText.lowercased()) ||
                prescription.details.joined(separator: ", ").lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct PrescriptionRow: View {
    var doctorName: String
    var date: String
    var details: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(doctorName)
                    .font(.headline)
                    .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
                Spacer()
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
            }
            Divider()
            Text(details)
                .font(.subheadline)
                .foregroundColor(.gray)
                .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
        }
        .padding(.vertical, 5)
    }
}

struct Prescription: Identifiable {
    let id = UUID()
    var doctorName: String
    var date: String
    var details: [String]
}

struct PrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionListView()
    }
}
