import SwiftUI

struct CustomSegmentedControlAppearance: UIViewRepresentable {
    var selectedColor: UIColor

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        UISegmentedControl.appearance().selectedSegmentTintColor = selectedColor
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct MyAppointmentsView: View {
    @State private var selectedSegment = 0

    var body: some View {
        VStack {
            Picker("Select", selection: $selectedSegment) {
                Text("Upcoming").tag(0)
                Text("Past").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                if selectedSegment == 0 {
                    ForEach(filteredAppointments(filter: "upcoming"), id: \.self) { appointment in
                        Text(appointment)
                            .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
                    }
                } else {
                    ForEach(filteredAppointments(filter: "past"), id: \.self) { appointment in
                        Text(appointment)
                            .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("") // Remove default navigation title
        .navigationBarTitleDisplayMode(.large) // Adjust display mode
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Appointments")
                    .font(.title2) // Adjust font size here
                    .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
            }
        }
        .background(Color.customBackground)
        .overlay(
            CustomSegmentedControlAppearance(selectedColor: UIColor(Color.customPrimary))
                .frame(width: 0, height: 0)
        )
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
