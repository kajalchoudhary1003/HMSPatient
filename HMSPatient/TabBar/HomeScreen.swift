import SwiftUI
import FirebaseAuth
import Combine

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var showingActionSheet = false
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
                HomeTab(searchViewModel: searchViewModel, showingActionSheet: $showingActionSheet)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            RecordsView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Records")
                }
                .tag(1)
        }
    }
}

struct HomeTab: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @State private var showingProfile = false
    @State private var profileImage: Image? = nil
    @State private var userFirstName: String = "User"
    private let dataController = DataController()
    @Binding var showingActionSheet: Bool

    @State private var selectedDoctor: Doctor?
    @State private var navigateToBookAppointment = false
    @State private var userId: String?
    @State private var appointments: [Appointment] = []

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if searchViewModel.isSearching {
                            searchResultsView
                        } else {
                            regularContent
                        }
                    }
                    .frame(width: geometry.size.width)
                }
            }
            .searchable(text: $searchViewModel.searchText, prompt: "Search doctors, illness, etc...")
            .background(Color.customBackground)
            .navigationTitle("Hi, \(userFirstName)")
            .background(Color(hex: "ECEEEE"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let url = URL(string: "tel://112") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "cross.circle.fill")
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(Color(hex: "0E6B60"))
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                PatientProfileView()
            }
            .onAppear {
                fetchUserData()
                fetchAppointments()
            }
            .background(NavigationLink(destination: BookAppointment(selectedDoctor: selectedDoctor), isActive: $navigateToBookAppointment){
                EmptyView()
            })
        }.navigationBarHidden(true)
    }

    var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Search Results")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            ForEach(searchViewModel.searchResults) { doctor in
                DoctorRowView(doctor: doctor, onSelect: { selectedDoctor in
                    self.selectedDoctor = selectedDoctor
                    self.navigateToBookAppointment = true
                })
            }
        }
        .padding()
    }

    var regularContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("My Appointments")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    NavigationLink(destination: MyAppointmentsView()) {
                        Text("See All")
                    }
                }
                ForEach(appointments) { appointment in
                    AppointmentCard(appointment: appointment)
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 7) {
                Text("Features")
                    .font(.title2)
                    .fontWeight(.bold)
                HStack {
                    NavigationLink(destination: BookAppointment()) {
                        FeatureCard(icon: "stethoscope", title: "Book an\nAppointment")
                    }
                    if let userId = userId {
                        NavigationLink(destination: PrescriptionListView(userId: userId)) {
                            FeatureCard(icon: "list.bullet.clipboard", title: "My\nPrescriptions")
                        }
                    }
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 7) {
                Text("For You")
                    .font(.title2)
                    .fontWeight(.bold)
                OfferCards()
            }
            .padding(.horizontal)
        }
    }

    private func fetchUserData() {
        if let user = Auth.auth().currentUser {
            self.userId = user.uid
            dataController.fetchCurrentUserData { user, image in
                if let user = user {
                    self.userFirstName = user.firstName
                }
                self.profileImage = image
            }
        }
    }

    private func fetchAppointments() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        dataController.fetchAppointments(userId: userId) { appointments in
            self.appointments = appointments
        }
    }
}


struct AppointmentCard: View {
    var appointment: Appointment

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(appointment.doctorName) // You need to fetch the doctor's name using the doctorID from the appointment
                    .font(.title)
                Text(appointment.doctorSpeciality) // You need to fetch the doctor's speciality using the doctorID from the appointment
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                Text(appointment.timeSlot) // You need to format the appointment date and time slot
                    .font(.subheadline)
                    .foregroundColor(.customPrimary)
            }
            Spacer()
//            VStack(alignment: .center) {
//                Text(appointment.day) // You need to format the appointment date to get the day
//                    .font(.subheadline)
//                    .fontWeight(.bold)
//                    .foregroundColor(.customPrimary)
//                Text(appointment.date) // You need to format the appointment date to get the date
//                    .font(.largeTitle)
//                    .fontWeight(.regular)
//            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
extension Appointment {
    var doctorName: String {
        // Fetch the doctor's name using the doctorID from the appointment
        return "Dr. \(doctorID ?? "")" // Placeholder
    }

    var doctorSpeciality: String {
        // Fetch the doctor's speciality using the doctorID from the appointment
        return "Speciality" // Placeholder
    }

    var timeSlot: String {
        // Format the appointment date and time slot
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }

    var day: String {
        // Format the appointment date to get the day
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}


struct FeatureCard: View {
    var icon: String
    var title: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(8)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.customPrimary))
            }
            Spacer()
            Text(title)
                .font(.headline)
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
