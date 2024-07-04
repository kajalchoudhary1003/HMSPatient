//
//  Dashboard.swift
//  HMSPatient
//
//  Created by Nakshatra Verma on 04/07/24.
//

import SwiftUI

struct CircleWithIcon: View {
    let backgroundColor: Color
    let icon: Image
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 100, height: 100)
            
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
        }
    }
}

struct Dashboard: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            RecordsView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Records")
                }
                .tag(1)
        }
        .background(Color(.systemGray6))
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                    
                    SearchBar()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Upcoming Appointments")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#006666"))
                        AppointmentCard()
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Features")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#006666"))
                        HStack {
                            FeatureCard(icon: "stethoscope.circle.fill", title: "Book an Appointment")
                            FeatureCard(icon: "", title: "My Prescriptions")
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("For You")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#006666"))
                        OfferCards()
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    /* Text(" ")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45)) */
                }
            }
        }
    }
}

struct RecordsView: View {
var body: some View {
NavigationView {
Text("No Records Found")
.font(.largeTitle)
.fontWeight(.bold)
.padding()
.navigationBarItems(
leading: Text("Records") // Set navigation bar title
.font(.largeTitle)
.fontWeight(.bold)
.foregroundColor(Color(hex: "#006666"))// Set color here
)
}
}
}

struct SearchBar: View {
@State private var searchText = ""

var body: some View {
HStack {
TextField("Search", text: $searchText)
.padding(7)
.padding(.horizontal, 25)
.background(Color(.white))
.cornerRadius(8)
.overlay(
HStack {
Image(systemName: "magnifyingglass")
.foregroundColor(.gray)
.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
.padding(.leading, 8)

if searchText != "" {
Button(action: {
self.searchText = ""
}) {
Image(systemName: "multiply.circle.fill")
.foregroundColor(.gray)
.padding(.trailing, 8)
}
}
}
)
.padding(.horizontal, 10)
}
}
}
struct AppointmentCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Dr. Renu Luthra")
                    .font(.headline)
                Text("Gynecologist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("10:15 - 10:35")
                    .font(.footnote)
                    .foregroundColor(Color(hex: "#006666"))
            }
            Spacer()
            VStack {
                Text("WED")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#006666"))
                Text("28")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                    .font(.title)
                    .foregroundColor(Color(hex: "#006666"))
            }
            Spacer()
            Text(title)
                .font(.custom("", size: 16))
                .foregroundColor(Color(hex: "#006666"))
        }
        .padding()
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct OfferCards: View {
    var body: some View {
        TabView {
            OfferCard(offerText: "% Off Offer: 1")
            OfferCard(offerText: "% Off Offer: 2")
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 100)
    }
}

struct OfferCard: View {
    var offerText: String
    
    var body: some View {
        Text(offerText)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
    }
}

