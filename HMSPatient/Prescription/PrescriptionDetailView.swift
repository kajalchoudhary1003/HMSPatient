import SwiftUI

struct PrescriptionDetailView: View {
    var date: Date
    var details: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Text(formatDate(date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 5) {
                
                    Text(details)
                        .font(.body)
                
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Prescription Details")
    }
    
    private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
}

//struct PrescriptionDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PrescriptionDetailView(date: "4 July, 2024 at 3:21 PM", details: [
//            "Amoxicillin (500mg) - 2 capsules",
//            "Ibuprofen (150mg) - 1 tablet",
//            "Omeprazole (400mg) - 3 tablets",
//            "Sertraline (500mg) - 2 capsules",
//            "Loratadine (320mg) - 2 tea spoons",
//            "Fluconazole (200mg) - 6 capsules"
//        ])
//    }
//}
//
//#Preview {
//    PrescriptionDetailView(date: "4 July, 2024 at 3:21 PM", details: [
//        "Amoxicillin (500mg) - 2 capsules",
//        "Ibuprofen (150mg) - 1 tablet",
//        "Omeprazole (400mg) - 3 tablets",
//        "Sertraline (500mg) - 2 capsules",
//        "Loratadine (320mg) - 2 tea spoons",
//        "Fluconazole (200mg) - 6 capsules"
//    ])
//}
