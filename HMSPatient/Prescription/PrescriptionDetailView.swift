import SwiftUI

struct PrescriptionDetailView: View {
    var date: String
    var details: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
                Spacer()
            }
            VStack(alignment: .leading, spacing: 5) {
                ForEach(details, id: \.self) { detail in
                    Text(detail)
                        .font(.body)
                        .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("") // Remove default navigation title
        .navigationBarTitleDisplayMode(.large) // Adjust display mode
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Prescription Details")
                    .font(.title2) // Adjust font size here
                    .dynamicTypeSize(.large ... .xxxLarge) // Added dynamic type size
            }
        }
    }
}

struct PrescriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionDetailView(date: "4 July, 2024 at 3:21 PM", details: [
            "Amoxicillin (500mg) - 2 capsules",
            "Ibuprofen (150mg) - 1 tablet",
            "Omeprazole (400mg) - 3 tablets",
            "Sertraline (500mg) - 2 capsules",
            "Loratadine (320mg) - 2 tea spoons",
            "Fluconazole (200mg) - 6 capsules"
        ])
    }
}
