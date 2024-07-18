import SwiftUI

struct PrescriptionListView: View {
    @State private var searchText = ""
    @State private var appointments: [Appointment] = []
    @State private var isLoading = true
    var userId: String
    
    // Sample prescription data
//    let prescriptions = [
//        Prescription(doctorName: "Dr. Seema Gupta", date: "4 July, 2024", details: ["Amoxicillin (500mg) - 2 capsules"]),
//        Prescription(doctorName: "Dr. Seema Gupta", date: "24 June, 2024", details: ["Sertraline (500mg) - 2 capsules"]),
//        Prescription(doctorName: "Dr. Rajesh Waghle", date: "10 June, 2024", details: ["Ibuprofen (150mg) - 1 tablet"]),
//        Prescription(doctorName: "Dr. Anmol Kriti", date: "6 May, 2024", details: ["Paracetamol (500mg) - 3 tablets"])
//    ]
    
    var body: some View {
            VStack {
                if isLoading{
                    ProgressView("Loading prescriptions...")
                } else if appointments.isEmpty{
                    Text("No prescriptions available")
                                           .foregroundColor(.gray)
                                           .font(.headline)
                                           .padding()
                }else{
                    
                    
                    List(filteredAppointments, id: \.id) { appointment in
                        NavigationLink(destination: PrescriptionDetailView(date: appointment.date, details: appointment.prescription ?? "")) {
                            PrescriptionRow(doctorName: appointment.doctorID ?? "Unknown doctor", date: formatDate(appointment.date), details: appointment.prescription ?? "No prescription")
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("My Prescriptions")
                    .navigationBarTitleDisplayMode(.large)
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                }
            }
            .onAppear{
                fetchAppointments()
            }
            .background(Color.customBackground)
        }
        
    
    // Computed property for filtered prescriptions
    var filteredAppointments: [Appointment] {
        if searchText.isEmpty {
            return appointments
        } else {
            return appointments.filter { appointment in
                (appointment.doctorID.lowercased().contains(searchText.lowercased()) ?? false) ||
                formatDate(appointment.date).lowercased().contains(searchText.lowercased()) ||
                (appointment.prescription?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    private func fetchAppointments(){
        DataController.shared.fetchAppointments(userId: userId){
            fetchedAppointments in
            self.appointments = fetchedAppointments.filter{$0.patientID == userId && $0.prescription != nil}
            self.isLoading = false
            
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
                Spacer()
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            }
            Divider()
            Text(details)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}

//struct Prescription: Identifiable {
//    let id = UUID()
//    var doctorName: String
//    var date: String
//    var details: [String]
//}

struct PrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionListView(userId: "sampleUserID")
    }
}
