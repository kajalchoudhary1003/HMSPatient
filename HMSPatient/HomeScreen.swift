import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Upcoming Appointments")
                                .font(.title2)
                                .fontWeight(.bold)
                            AppointmentCard()
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Features")
                                .font(.title2)
                                .fontWeight(.bold)
                            HStack {
                                FeatureCard(icon: "stethoscope.circle.fill", title: "Book an\nAppointment")
                                FeatureCard(icon: "newspaper.circle.fill", title: "My\nPrescriptions")
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
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Hi, User").font(.largeTitle).bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            // Emergency Button Action
                            if let url = URL(string: "tel://112") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "cross.circle.fill")
                                .foregroundColor(Color(UIColor.systemRed))
                        }
                        Button(action: {
                            // Profile Button Action
                        }) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationBarBackButtonHidden(true) // Hide the back button
        }
    }
}

struct AppointmentCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Dr. Renu Luthra")
                    .font(.title)
                Text("Gynecologist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("10:15 - 10:35")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("WED")
                    .padding(.trailing, 6)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                Text("28")
                    .font(.largeTitle)
                    .fontWeight(.bold)
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
        Button(action: {
            // Add your action here
            print("Tapped on \(title)")
        }) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                }
                Spacer()
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
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
                .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}

struct RecordsView: View { // Ensure this struct name is unique
    var body: some View {
        Text("Records View")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
