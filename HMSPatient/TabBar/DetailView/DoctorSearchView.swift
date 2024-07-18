import SwiftUI

struct DoctorRowView: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(doctor.name)
                .font(.title2)
                .foregroundColor(.black)
                .dynamicTypeSize(.large ... .xxxLarge)
            
            if doctor.name != "Select Doctor" {
                Text("Age: \(calculateAge(from: doctor.dob))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .dynamicTypeSize(.large ... .xxxLarge)
                
                HStack {
                    Text("Experience: \(doctor.experience) years")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .dynamicTypeSize(.large ... .xxxLarge)
                    
                    Spacer()
                    
                    Text(String(format: "Fees: %@", doctor.fees))
                        .font(.footnote)
                        .foregroundColor(.customPrimary)
                        .dynamicTypeSize(.large ... .xxxLarge)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .onAppear {
            print("DoctorCardView appeared for \(doctor.name)")
        }
    }
}


