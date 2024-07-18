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
            }
        }.navigationBarHidden(true)
    }
    
    var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Search Results")
                .font(.title2)
                .fontWeight(.bold)
                .dynamicTypeSize(.large ... .xxxLarge)
                .padding(.horizontal)
            
            ForEach(searchViewModel.searchResults) { doctor in
                DoctorRowView(doctor: doctor)
                    .onTapGesture {
                        selectedDoctor = doctor
                        navigateToBookAppointment = true
                    }
            }
        }.padding()
    }
    
    var regularContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("My Appointments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .dynamicTypeSize(.large ... .xxxLarge)
                    
                    Spacer()
                    
                    NavigationLink(destination: MyAppointmentsView()) {
                        Text("See All")
                            .dynamicTypeSize(.large ... .xxxLarge)
                    }
                }
                AppointmentCard()
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 7) {
                Text("Features")
                    .font(.title2)
                    .fontWeight(.bold)
                    .dynamicTypeSize(.large ... .xxxLarge)
                HStack {
                    NavigationLink(destination: BookAppointment()) {
                        FeatureCard(icon: "stethoscope", title: "Book an\nAppointment")
                    }.dynamicTypeSize(.large ... .xxxLarge)
                    NavigationLink(destination: PrescriptionListView()) {
                        FeatureCard(icon: "list.bullet.clipboard", title: "My\nPrescriptions")
                    }.dynamicTypeSize(.large ... .xxxLarge)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 7) {
                Text("For You")
                    .font(.title2)
                    .fontWeight(.bold)
                    .dynamicTypeSize(.large ... .xxxLarge)
                OfferCards()
            }
            .padding(.horizontal)
        }
    }
    
    private func fetchUserData() {
        dataController.fetchCurrentUserData { user, image in
            if let user = user {
                self.userFirstName = user.firstName
            }
            self.profileImage = image
        }
    }
}


struct AppointmentCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Dr. Renu Luthra")
                    .font(.title3)
                    .dynamicTypeSize(.large ... .xxxLarge)
                Text("Gynecologist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                    .dynamicTypeSize(.large ... .xxxLarge)
                Text("10:15 - 10:35")
                    .font(.subheadline)
                    .foregroundColor(.customPrimary)
                    .dynamicTypeSize(.large ... .xxxLarge)
            }
            Spacer()
            VStack(alignment: .center) {
                Text("WED")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.customPrimary)
                    .dynamicTypeSize(.large ... .xxxLarge)
                Text("28")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .dynamicTypeSize(.large ... .xxxLarge)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
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
                    .resizable()
                    .scaledToFit()
                    .font(.title2) // Consistent font size for the icon
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(8)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.customPrimary))
            }
            Spacer()
            Text(title)
                .font(.headline) // Adjust based on desired text size
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
                .dynamicTypeSize(.large ... .xxxLarge) // Add dynamic type size here
                .lineLimit(nil) // Allow text to wrap and resize as needed
        }
        .frame(height: 130) // Adjust height as needed to accommodate resized text
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
