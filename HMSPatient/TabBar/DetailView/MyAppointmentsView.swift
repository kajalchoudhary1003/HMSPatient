import SwiftUI

struct MyAppointmentsView: View {
    @State private var selectedSegment = 0

    var body: some View {
            VStack {
                Picker("Select", selection: $selectedSegment) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(Color(hex: "0E6B60"))
                .padding()

                List {
                    if selectedSegment == 0 {
                        ForEach(filteredAppointments(filter: "upcoming"), id: \.self) { appointment in
                            Text(appointment)
                        }
                    } else {
                        ForEach(filteredAppointments(filter: "past"), id: \.self) { appointment in
                            Text(appointment)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("My Appointments")
                .navigationBarTitleDisplayMode(.large)
            }
            .background(Color(hex: "ECEEEE"))
    }

    func filteredAppointments(filter: String) -> [String] {
        if filter == "upcoming" {
            return ["Upcoming Appointment 1", "Upcoming Appointment 2"]
        } else {
            return ["Past Appointment 1", "Past Appointment 2"]
        }
    }
}

#Preview {
    MyAppointmentsView()
}
