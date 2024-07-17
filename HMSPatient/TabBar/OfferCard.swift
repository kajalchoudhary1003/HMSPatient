//
//  OfferCard.swift
//  HMSPatient
//
//  Created by pushker yadav on 17/07/24.
//

import SwiftUI

struct OfferCards: View {
    var body: some View {
        TabView {
            OfferCard(imageName: "1", url: "https://www.example.com/offer1")
            OfferCard(imageName: "2", url: "https://www.example.com/offer2")
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width:.infinity,height: 133,alignment: .center)
        .font(.title)
    }
}

struct OfferCard: View {
    var imageName: String
    var url: String

    var body: some View {
        Button(action: {
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        }) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(10)
        }
        .padding(.horizontal, 5)
    }
}
