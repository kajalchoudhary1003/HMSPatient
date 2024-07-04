import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Top section
            HStack {
                Text("Hi, User")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    // Emergency Button Action
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                Button(action: {
                    // Profile Button Action
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SearchBar()
                        .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Upcoming Appointments")
                            .font(.title2)
                            .fontWeight(.bold)
                        AppointmentCard()
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                        HStack {
                            FeatureCard(icon: "stethoscope.circle.fill", title: "Book an\nAppointment")
                            FeatureCard(icon: "newspaper.circle.fill", title: "My\nPrescriptions")
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("For You")
                            .font(.title2)
                            .fontWeight(.bold)
                        OfferCards()
                    }
                    .padding(.horizontal)
                }
            }

            // Bottom Tab Bar
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                Spacer()
                Spacer()
                VStack {
                    Image(systemName: "doc.text")
                    Text("Records")
                }
                .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .background(Color.white)
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SearchBar: View {
    @State private var searchText = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $searchText)
            Image(systemName: "mic")
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct AppointmentCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Dr. Renu Luthra")
                    .font(.headline)
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
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                Text("28")
                    .font(.title)
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
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
            }
            Spacer()
            Text(title)
                .font(.subheadline)
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

struct OfferCards: View {
    var body: some View {
        TabView {
            OfferCard(offerText: "% Off Offer: 1")
            OfferCard(offerText: "% Off Offer: 2")
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 100)
    }
}

struct OfferCard: View {
    var offerText: String

    var body: some View {
        Text(offerText)
            .padding()
            .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10)
    }
}
