import SwiftUI

struct DoctorRowView: View {
    let doctor: Doctor
    let onSelect: (Doctor) -> Void
    
    var body: some View {
        Button(action: {onSelect(doctor)}){
            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.name)
                    .font(.title2)
                    .foregroundColor(Color("TextColor"))
                
                if doctor.name != "Select Doctor" {
                    Text("Age: \(calculateAge(from: doctor.dob))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Experience: \(doctor.experience) years")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(String(format: "Fees: %@", doctor.fees))
                            .font(.footnote)
                            .foregroundColor(.customPrimary)
                    }
                }
            }
            .padding()
            .background(Color("SecondaryColor"))
            .cornerRadius(10)
            .onAppear {
                print("DoctorCardView appeared for \(doctor.name)")
            }
        }
    }
}
