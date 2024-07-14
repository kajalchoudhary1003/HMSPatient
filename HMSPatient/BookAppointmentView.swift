import SwiftUI
import CoreLocation

struct DoctorListView: View {
    @State private var doctors: [Doctor] = []
    @State private var nearestHospital: Hospital?
    @State private var isLoading = true
    @State private var userLocation: CLLocation? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading doctors...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            fetchUserLocation()
                        }
                } else if doctors.isEmpty {
                    VStack {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        Text("No Doctors Available")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        Text("No doctors found in the nearest hospital.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(doctors) { doctor in
                                NavigationLink(destination: BookAppointmentView(doctor: doctor, hospital: nearestHospital)) {
                                    DoctorCardView(doctor: doctor)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(hex: "ECEEEE"))
                }
            }
            .navigationTitle("Doctors")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func fetchUserLocation() {
        // Simulating user location for demonstration. Replace with actual location fetching logic.
        self.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // Example location (San Francisco)
        fetchNearestHospital()
    }
    
    private func fetchNearestHospital() {
        guard let userLocation = userLocation else { return }
        
        DataController.shared.getNearestHospital(userLocation: userLocation) { hospital in
            if let hospital = hospital {
                self.nearestHospital = hospital
                self.doctors = hospital.admins.flatMap { admin in
                    DataController.shared.getDoctors().filter { $0.designation == .generalPractitioner } // Example filtering
                }
            }
            self.isLoading = false
        }
    }
}

struct DoctorCardView: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(doctor.firstName) \(doctor.lastName)")
                .font(.headline)
            Text(doctor.designation.title)
                .font(.subheadline)
            Text("Fees: \(doctor.fees)")
                .font(.caption)
            Text("Consultation Time: \(doctor.interval)")
                .font(.caption)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct BookAppointmentView: View {
    let doctor: Doctor
    let hospital: Hospital?
    
    var body: some View {
        VStack {
            Text("Booking Appointment with Dr. \(doctor.firstName) \(doctor.lastName)")
            // Add your booking appointment UI here
        }
        .navigationTitle("Book Appointment")
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xff0000) >> 16) / 0xff
        let green = Double((rgbValue & 0xff00) >> 8) / 0xff
        let blue = Double(rgbValue & 0xff) / 0xff
        self.init(red: red, green: green, blue: blue)
    }
}

struct DoctorListView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorListView()
    }
}

