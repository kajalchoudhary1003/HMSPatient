import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var showingActionSheet = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab(showingActionSheet: $showingActionSheet)
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
    @State private var searchText = ""
    @State private var showingProfile = false
    @State private var profileImage: Image? = nil
    @State private var userFirstName: String = "User"
    private let dataController = DataController()
    @Binding var showingActionSheet: Bool

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 5) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 7) {
                                HStack{
                                    Text("My Appointments")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: MyAppointmentsView()) {
                                        Text("See All")
                                    }
                                }
                                AppointmentCard()
                            }
                            .padding(.horizontal)
                            .padding(.top, 7)
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Features")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                HStack {
                                    NavigationLink(destination: BookAppointment()){
                                        FeatureCard(icon: "stethoscope", title: "Book an\nAppointment")
                                    }
                                    NavigationLink(destination: PrescriptionListView()) {
                                        FeatureCard(icon: "list.bullet.clipboard", title: "My\nPrescriptions")
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
                        .frame(width: geometry.size.width) // Ensure ScrollView does not exceed the screen width
                    }
                }
            }
            .searchable(text: $searchText)
            .background(Color.customBackground)
            .navigationBarTitle("Hi, \(userFirstName)")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                                            showingActionSheet = true
                                        }) {
                                            Image(systemName: "cross.circle.fill")
                                                .foregroundColor(Color(UIColor.systemRed))
                                        }
                                        .actionSheet(isPresented: $showingActionSheet) {
                                            ActionSheet(title: Text("Call Ambulance"), buttons: [
                                                .destructive(Text("Call 112")) {
                                                    if let url = URL(string: "tel://112") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                },
                                                .cancel()
                                            ])
                                        }
                    Button(action: {
                        showingProfile = true
                    }) {
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(width: 30, height: 30)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.customPrimary)
                        }
                    }
                    .sheet(isPresented: $showingProfile) {
                        PatientProfileView()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchUserData()
        }
    }

    func fetchUserData() {
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
                    .font(.title)
                Text("Gynecologist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                Text("10:15 - 10:35")
                    .font(.subheadline)
                    .foregroundColor(.customPrimary)
            }
            Spacer()
            VStack(alignment: .center) {
                Text("WED")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.customPrimary)
                Text("28")
                    .font(.largeTitle)
                    .fontWeight(.regular)
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

struct OfferCards: View {
    var body: some View {
        TabView {
            OfferCard(offerText: "% Off Offer: 1")
            OfferCard(offerText: "% Off Offer: 2")
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 100)
        .font(.title)
    }
}

struct OfferCard: View {
    var offerText: String

    var body: some View {
        Button(action: {
            print("Tapped on offer: \(offerText)")
        }) {
            Text(offerText)
                .padding()
                .foregroundColor(.customPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 5)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
